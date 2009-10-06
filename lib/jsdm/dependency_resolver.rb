require 'jsdm/errors'

class JSDM
  class DependencyResolver
    attr_accessor :load_path
    
    def initialize(load_path)
      if load_path.is_a? Array
        self.load_path = load_path
      else
        self.load_path = [load_path]
      end
    end
    
    def process(entries)
      entries.map { |entry| process_single entry }.flatten
    end

    def process_single(entry)
      resolved = load_path.map { |path| Dir["#{path}/#{entry.strip}"] }.
                           drop_while { |sources| sources.empty? }.
                           first
      raise FileNotFoundError.new(entry) if resolved.nil? || resolved.empty?
      resolved
    end
  end
end
  
