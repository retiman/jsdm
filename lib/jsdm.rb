require 'jsdm/dependency_manager'
require 'jsdm/dependency_resolver'
require 'jsdm/errors'
require 'jsdm/preprocessor'

# JSDM allows you to add #require statements to JavaScript and then manages
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

  def initialize(opts = {})
    defaults = {
      :randomize       => true,
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

  # Preprocesses, resolves, and sorts the source files.  Here's how it does it:
  #
  # * Gather all the sources in the load path
  # * Optionally sort them to ensure that dependencies have been set correctly
  # * Create the Preprocessor, DependencyResolver, and DependencyManager
  # * Preprocess the source files and resolve the dependencies
  # * Add each individual dependency to the DependencyManager
  # * Have the DependencyManager perform a topological sort
  def process
    self.sources      = options[:load_path].map { |path|
                          Dir[File.join(path, '**', "*.#{options[:extension]}")]
                        }.flatten
    self.sources      = sources.sort { rand } if options[:randomize]
    self.preprocessor = Preprocessor.new       sources, options
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

  # Returns an associative list of sources mapped to source dependencies
  def dependencies
    manager.dependencies
  end

  # Returns the dependencies of a source file, as an array of strings
  def dependencies_for(source)
    manager.dependencies_for(source)
  end

  # Returns the dependencies of a source file (and the source file itself) as
  # an array of strings
  def sources_for(source)
    dependencies_for(source) << source
  end

  # Returns the require statements for a source file
  def requires_for(source)
    requires.select { |r| r.first == source }.first.last
  end
end
