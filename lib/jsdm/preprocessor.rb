class JSDM
  class Preprocessor
    attr_accessor :sources, :comment_pattern, :require_pattern, :options


    def initialize(sources, options = {})
      defaults = {
        :comment_pattern => Preprocessor.cp,
        :require_pattern => Preprocessor.rp
      }
      self.sources = sources
      self.options = defaults.merge options
    end

    def process_single(source)
      File.open(source).
           each_line.
           take_while { |line| line =~ options[:comment_pattern] }.
           select { |line| line =~ options[:require_pattern] }.
           map { |line| line.sub!(options[:require_pattern], "").split(",") }.
           flatten.
           map { |entry| entry.strip }
    end

    def process
      sources.map { |source| [source, process_single(source)] }
    end

    class << self
      attr_accessor :cp, :rp
      private :cp=, :rp=
    end

    self.cp = /^\s*\/\/\s*/
    self.rp = /#{self.cp}#\s*require\s*/
  end
end
