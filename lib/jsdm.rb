require 'jsdm/dependency_manager'
require 'jsdm/dependency_resolver'
require 'jsdm/errors'
require 'jsdm/preprocessor'

class JSDM
  attr_accessor :load_path, :sources, :preprocessor, :manager, :resolver, :ext,
                :injected, :processed

  def initialize(load_path = [], options = {})
    self.load_path    = load_path.is_a?(Array) ? load_path : [load_path]
    self.sources      = []
    self.injected     = []
    self.preprocessor = nil
    self.manager      = nil
    self.resolver     = nil
    self.ext          = "js"
  end

  def process!
    self.sources      = load_path.map { |path| Dir["#{path}/**/*.#{ext}"] }.
                                  flatten.
                                  sort
    self.sources      = sources.sort { rand }
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
  def concatenate(output_file, data_files, options = {})
    JSDM.concatenate(output_file, data_files, options)
  end

  def sources_in(dirs)
    dirs = dirs.is_a?(Array) ? dirs : [dirs]
    requested = dirs.map { |dir| Dir["#{dir}/**/*.#{ext}"] }.flatten
    sources & requested
  end

  def dependencies
    manager.dependencies
  end

  def self.js_check(files, options = {})
    Spidermonkey.check files, options
  end

  def self.concatenate(output_file, data_files, options = {})
    options = { :heading => "// $FILE$:" }.merge! options
    File.open(output_file, "w") do |file|
      data_files.each do |f|
        file.puts options[:heading].gsub(/\$FILE\$/, f)
        file.puts File.new(f).read
      end
    end
  end

  def self.same_file?(a, b)
    File.expand_path(a) == File.expand_path(b)
  end
end
