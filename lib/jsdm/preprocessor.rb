require 'jsdm/file_not_found_error'

module JSDM
  class Preprocessor
    def initialize(load_path, options = {})
      defaults = {
        :comment_pattern => /^\s*\/\/\s*/,
        :require_pattern => /^\s*\/\/\s*#require\s*/      
      }
      self.load_path = load_path
      self.manager   = DependencyManager.new(load_path)
      self.options   = defaults.merge! options
      check_load_path
    end

    def check_load_path
      load_path.each do |path|
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
      load_path.map { |path| Dir["#{path}/**/*.js"] }.flatten
    end    


    attr_accessor :manager, :load_path, :options
    private :manager=, :load_path=, :options=
  end
end