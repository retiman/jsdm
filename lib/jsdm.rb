require 'jsdm/dependency_manager'
require 'jsdm/dependency_resolver'
require 'jsdm/preprocessor'
require 'jsdm/spidermonkey'

class JSDM
  attr_accessor :load_path, :preprocessor, :manager, :resolver, :ext

  def initialize(load_path = [])
    self.load_path    = load_path
    self.preprocessor = nil
    self.manager      = nil
    self.resolver     = nil
    self.ext          = "js"
  end  
  
  def process
    self.sources      = load_path.map { |path| Dir["#{path}/**/*.#{ext}"] }.
                                  flatten.
                                  sort
    self.preprocessor = JSDM::Preprocessor.new       sources
    self.manager      = JSDM::DependencyManager.new  sources
    self.resolver     = JSDM::DependencyResolver.new load_path
    preprocessor.process.each do |element|
      source       = element.first
      dependencies = resolver.process(element.last)
      dependencies.each do |dependency|
        manager.add_dependency source, dependency
      end
    end
    self.sources = manager.process
    sources
  end

  def dependencies
    manager.dependencies
  end

  def concatenate(output_name, files = sorted_sources)
    File.open(output_name, "w") do |output|
      files.each do |file|
        output.puts "// #{file}:"
        output.puts File.new(file).read
        puts "Appended file: #{file}" if options[:verbose]
      end
    end
  end

  def js_check(files = sorted_sources, options = {})
    Spidermonkey.new(files, options).check
  end
   
  def self.same_file?(a, b)
    File.expand_path(a) == File.expand_path(b)
  end
end
