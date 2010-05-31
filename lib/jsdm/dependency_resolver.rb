require 'jsdm/errors'

class JSDM
  class DependencyResolver
    attr_accessor :load_path

    def initialize(load_path)
      self.load_path = load_path
    end

    def process(entries)
      entries.map { |entry| process_single entry }.
              flatten
    end

    def process_single(entry)
      resolved = load_path.map { |path| Dir[File.join(path, entry.strip)] }
      resolved = resolved.drop_while { |sources| sources.empty? }
      resolved = resolved.first
      raise FileNotFoundError.new(entry) if resolved.nil? || resolved.empty?
      resolved
    end
  end
end

