require 'jsdm/dependency_manager'
require 'jsdm/dependency_resolver'
require 'jsdm/errors'
require 'jsdm/preprocessor'
require 'jsdm/spidermonkey'

class JSDM
  attr_accessor :load_path, :sources, :preprocessor, :manager, :resolver, :ext

  def initialize(load_path = [])
    self.load_path    = load_path.is_a?(Array) ? load_path : [load_path]
    self.sources      = []
    self.preprocessor = nil
    self.manager      = nil
    self.resolver     = nil
    self.ext          = "js"
  end  
  
  def process!
    self.sources      = load_path.map { |path| Dir["#{path}/**/*.#{ext}"] }.
                                  flatten.
                                  sort
    self.preprocessor = JSDM::Preprocessor.new       sources
    self.manager      = JSDM::DependencyManager.new  sources
    self.resolver     = JSDM::DependencyResolver.new load_path
    preprocessor.process.each do |element|
      begin
        source       = element.first
        dependencies = resolver.process(element.last)
        dependencies.each do |dependency|
          manager.add_dependency source, dependency
        end
      rescue JSDM::FileNotFoundError => e
        raise JSDM::UnsatisfiableDependencyError.new(source, e.file)
      end
    end
    self.sources = manager.process
    sources
  end
  
  def sources_in(dir)
    sources & Dir["#{dir}/**/*.#{ext}"]
  end

  def dependencies
    manager.dependencies
  end

  def self.js_check(files)
    Spidermonkey.check(files)
  end

  def self.concatenate(output_file, data_files)
    File.open(output_file, "w") do |file|
      data_files.each do |f|
        file.puts "// #{f}:"
        file.puts File.new(f).read
      end
    end
  end
   
  def self.same_file?(a, b)
    File.expand_path(a) == File.expand_path(b)
  end
end
