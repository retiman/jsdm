require 'jsdm/dependency_manager'
require 'jsdm/file_not_found_error'

class JSDM
  class Preprocessor
    def initialize(load_path, options = {})
      comment_pattern = /^\s*\/\/\s*/
      defaults = {
        :verbose         => false,
        :extension       => "js",
        :comment_pattern => comment_pattern,
        :require_pattern => /#{comment_pattern}#require\s*/,
        :randomize       => false
      }
      self.load_path = load_path
      self.manager   = DependencyManager.new load_path, options
      self.options   = defaults.merge! options
      check_load_path
    end

    def check_load_path
      puts "Preprocessor started with load path:" if options[:verbose]
      load_path.each do |path|
        puts "  #{path}" if options[:verbose]
        raise FileNotFoundError.new(path) if !File.directory? path
      end
    end
    
    def get_includes_from(source)         
      File.open(source).
           each_line.
           take_while { |line| line =~ options[:comment_pattern] }.
           select { |line| line =~ options[:require_pattern] }.
           map { |line| line.sub!(options[:require_pattern], "").split(",") }.
           flatten.
           map { |entry| entry.strip }
    end
    
    def process
      get_all_sources.each do |source|
        includes = get_includes_from(source)
        manager.add_dependencies(source, includes)
      end
      manager.process
    end    

    # todo: refactor out of class
    def get_all_sources
      ext = options[:extension]
      sources = load_path.map { |path| Dir["#{path}/**/*.#{ext}"] }.flatten
      sources.sort { rand } # add this as an option
    end    


    attr_accessor :manager, :load_path, :options
  end
end
