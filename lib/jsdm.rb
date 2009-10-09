require 'jsdm/dependency_manager'
require 'jsdm/dependency_resolver'
require 'jsdm/errors'
require 'jsdm/preprocessor'
require 'jsdm/spidermonkey'

class JSDM
  attr_accessor :load_path, :sources, :preprocessor, :manager, :resolver, :ext,
                :injected, :processed, :options

  # options is deprecated
  def initialize(load_path = [], options = {})
    self.load_path    = load_path.is_a?(Array) ? load_path : [load_path]
    self.sources      = []
    self.injected     = []
    self.preprocessor = nil
    self.manager      = nil
    self.resolver     = nil
    self.ext          = "js"
    self.processed    = false # deprecated
    self.options      = { :randomize => false }.merge(options) # deprecated
  end  
  
  def process!
    self.sources      = load_path.map { |path| Dir["#{path}/**/*.#{ext}"] }.
                                  flatten.
                                  sort
    self.sources      = sources.sort { rand } if options[:randomize]
    self.preprocessor = Preprocessor.new       sources
    self.manager      = DependencyManager.new  sources
    self.resolver     = DependencyResolver.new load_path
    begin
      source = nil
      preprocessor.process.each do |element|
        source = element.first
        dependencies = resolver.process element.last
        dependencies.each do |dependency|
          manager.add_dependency source, dependency
        end
      end
      injected.each do |element|
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

  # deprecated
  def sorted_sources
    process! if !processed
    self.processed = true
    sources
  end

  # deprecated
  def sorted_sources_matching(dirs)
    process! if !processed
    self.processed = true
    sources_in(dirs)
  end
   
  # deprecated
  def js_check(files)
    JSDM.js_check(files)
  end

  # deprecated
  def concatenate(output_file, data_files)
    JSDM.concatenate(output_file, data_files)
  end

  def sources_in(dirs)
    dirs = dirs.is_a?(Array) ? dirs : [dirs]
    requested = dirs.map { |dir| Dir["#{dir}/**/*.#{ext}"] }.flatten
    sources & requested
  end

  def dependencies
    manager.dependencies
  end

  def self.js_check(files)
    Spidermonkey.check(files)
  end

  def self.concatenate(output_file, data_files, heading = "")
    File.open(output_file, "w") do |file|
      data_files.each do |f|
        file.puts heading.gsub(/\$FILE\$/, f)
        file.puts File.new(f).read
      end
    end
  end
   
  def self.same_file?(a, b)
    File.expand_path(a) == File.expand_path(b)
  end
end
