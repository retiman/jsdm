require 'jsdm/dependency_manager'
require 'jsdm/dependency_resolver'
require 'jsdm/errors'
require 'jsdm/preprocessor'

# JSDM allows you to add \#require statements to JavaScript and then manages
# the dependencies for you.  You may place the JavaScript files in many
# different directories, and then add those directories to your load path.
#
# JSDM will scan those directories, resolve your dependencies, and return to
# you a list of sources sorted topologically (that is, dependent sources
# come first).  You may then use that list to generate script tags, load them
# in Spidermonkey for syntax checking, or whatever else you like.
#
# Here's a quick example of how to use JSDM:
#
#   jsdm = JSDM.new :load_path => %w(/path1 /path2 /path3)
#   jsdm.sources.each do |source|
#     puts source
#   end
class JSDM
  attr_accessor :options,
                :sources,
                :requires,
                :preprocessor,
                :manager,
                :resolver

  # Options: randomize sort load_path extension comment_pattern require_pattern
  #
  # Creates an instance of a JSDM class which will let you retrieve dependency
  # information about your source files.  Use the specific instance methods to
  # retrieve this information.
  #
  # You may give JSDM a set of <tt>load_path</tt>s to search; in which case,
  # the first file in the load path that matches a require directive will be
  # the file JSDM considers to be the dependency.
  #
  # For example, suppose your load path consists of /foo and /bar.  Both
  # directories contain baz.js.  If bif.js declares baz.js as a dependency,
  # then during the dependency resolution step, /foo/baz.js will be considered
  # a dependency, and /bar/baz.js will not be.
  #
  # However, if you ask for <tt>jsdm.sources</tt>, all sources, including
  # /bar/baz.js will be returned.
  #
  # JavaScript source files should place \#require directives inside comments
  # at the top of the source file, so that JSDM can parse and process them.
  # You may use globs in your \#require directives.
  #
  # Here is an example of what one of your JavaScript files might look like:
  #
  #   // #require a.js
  #   // #require b.js
  #   // #require c/d.js
  #   // #require e/*.js
  #   // #require f/**/*.js
  #
  # It is advised to not use globs in your \#require directives if you
  # use multiple load paths, as \#require *.js will automatically
  # always resolve to all .js files in the first directory of your load path.
  #
  # For example:
  #
  # * Suppose directory /foo contains a.js, b.js, c.js
  # * Suppose directory /bar contains d.js
  # * Suppose a.js has a // \#require *.js comment
  #
  # Note that in the following example, /bar/d.js is not a dependency of a.js
  #
  #   jsdm = JSDM.new :load_path => %w(/foo /bar)
  #   pp jsdm.sources_for '/foo/a.js' # ['/foo/a.js', '/foo/b.js', '/foo/c.js']
  #   pp jsdm.sources # ['/foo/a.js', '/foo/b.js', '/foo/c.js', '/bar/d.js']
  #
  # Here are some more examples:
  #
  #   # Implicitly finds JavaScript files in the current directory, and prints
  #   # them:
  #   jsdm = JSDM.new
  #   jsdm.sources.each { |source| puts source }
  #
  #   # Finds both .js and .jsm files in the current directory, and prints
  #   # them:
  #   jsdm = JSDM.new :extension => '{js,jsm}'
  #   jsdm.sources.each { |source| puts source }
  #
  #   # Finds JavaScript files in two different directories, and prints file
  #   # from both directories:
  #
  #   jsdm = JSDM.new :load_path => %w(some/path some/other/path)
  #   jsdm.sources.each { |source| puts source }
  #
  #   # Sorts the JavaScript files beforehand; ensures a unique ordering of
  #   # dependencies, even if you've made a mistake in specifying the require
  #   # statements:
  #   jsdm = JSDM.new :sort => true
  #   jsdm.sources.each { |source| puts source }
  #
  #   # Randomizes the JavaScript files beforehand; hopefully ensures that you
  #   # will get an error from improperly specifying dependencies:
  #   jsdm = JSDM.new :randomize => true
  #   jsdm.sources.each { |source| puts source }
  #
  #   # Make the directive for requiring files @import instead of #require:
  #   JSDM.new :require_pattern => /^\s*\/\/\s*@import\s*/
  #   jsdm.sources.each { |source| puts source }
  def initialize(opts = {})
    defaults = {
      :randomize       => false,
      :sort            => true,
      :load_path       => '.',
      :extension       => 'js',
      :comment_pattern => Preprocessor.comment_pattern,
      :require_pattern => Preprocessor.require_pattern
    }
    self.options      = defaults.merge opts
    self.sources      = []
    self.preprocessor = nil
    self.manager      = nil
    self.resolver     = nil
    unless options[:load_path].is_a?(Array)
      options[:load_path] = [options[:load_path]]
    end
    process
  end

  # Returns an array of all JavaScript files in your <tt>load_path</tt>, sorted
  # so that dependent files are ordered first.  This method is called by the
  # initializer and the sorted array of JavaScript files will be stored in the
  # <tt>sources</tt> variable for the user.
  #
  # If you are only interested in sources from a particular load path, or for
  # a particular source file, see <tt>sources_for</tt> or
  # <tt>dependencies</tt>.
  #
  # Examples:
  #
  #   # Prints out sources from all load paths, in the correct order
  #   jsdm = JSDM.new :load_path => %w(path1 path2 path3)
  #   jsdm.sources.each { |source| puts source }
  def process
    self.sources      = options[:load_path].map { |path|
                          Dir[File.join(path, '**', "*.#{options[:extension]}")]
                        }.flatten
    self.sources      = sources.sort if options[:sort]
    self.sources      = sources.sort_by { rand } if options[:randomize]
    self.preprocessor = Preprocessor.new sources, options
    self.manager      = DependencyManager.new  sources
    self.resolver     = DependencyResolver.new options[:load_path]
    self.requires     = preprocessor.process
    begin
      source = nil
      requires.each do |element|
        source = element.first
        dependencies = resolver.process element.last
        dependencies.each do |dependency|
          manager.add_dependency source, dependency
        end
      end
    rescue FileNotFoundError => e
      raise UnsatisfiableDependencyError.new(source, e.file)
    end
    self.sources = manager.process
    sources
  end

  # Returns an associative list of sources mapped to source dependencies.  The
  # order of source dependencies is not guaranteed to be anything meaningful.
  # See <tt>dependencies_for</tt> if you want a list of dependencies in sorted
  # order.
  def dependencies
    manager.dependencies
  end

  # Returns the dependencies, and transitive dependencies, of a source file as
  # an array of strings, with the load path prepended to the file name.  The
  # dependencies are guaranteed to be in sorted order, so that dependent files
  # come first.
  #
  # Example(s):
  #
  #   # Print a list of dependencies for each source file.
  #   jsdm = JSDM.new
  #   jsdm.sources.each |source| { pp jsdm.dependencies_for source }
  def dependencies_for(source)
    manager.dependencies_for(source)
  end

  # Returns the dependencies, and transitive dependencies, of a source file,
  # as well as the source file itself, as an array of strings, with the load path
  # prepended to the file name.
  #
  # The dependencies are guaranteed to be in sorted order, so that dependent
  # files come first.
  def sources_for(source)
    dependencies_for(source) << source
  end

  # Returns the require statements for a source file, as a list of strings.
  # These are the actual \#require directives for the source file.
  def requires_for(source)
    requires.select { |r| r.first == source }.first.last
  end
end
