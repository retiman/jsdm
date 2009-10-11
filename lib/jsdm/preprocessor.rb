class JSDM
  class Preprocessor
    attr_accessor :sources, :comment_pattern, :require_pattern

    def initialize(sources)
      self.sources = sources
      self.comment_pattern = /^\s*\/\/\s*/
      self.require_pattern = /#{comment_pattern}#\s*require\s*/
    end
    
    def process_single(source)         
      File.open(source).
           each_line.
           take_while { |line| line =~ comment_pattern }.
           select { |line| line =~ require_pattern }.
           map { |line| line.sub!(require_pattern, "").split(",") }.
           flatten.
           map { |entry| entry.strip }
    end
    
    def process
      sources.map { |source| [source, process_single(source)] }
    end
  end
end
