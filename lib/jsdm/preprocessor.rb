class JSDM
  # Preprocesses the JavaScript for the DependencyResolver
  class Preprocessor
    attr_accessor :sources, :options

    def initialize(sources, options = {})
      defaults = {
        :comment_pattern => Preprocessor.comment_pattern,
        :require_pattern => Preprocessor.require_pattern
      }
      self.sources = sources
      self.options = defaults.merge options
    end

    # Processes a single source file for its dependencies so that they may be
    # resolved.  Here's how this function does it:
    #
    # * Open the source file and read it, taking all the lines that match the
    #   comment_pattern
    # * Select the lines that match the require_pattern from those lines
    # * Split each require statement with a comma in it
    # * Flatten the array of dependencies
    # * Strip out the trailing whitespace
    def process_single(source)
      File.open(source).
           each_line.
           take_while { |line| line =~ options[:comment_pattern] }.
           select { |line| line =~ options[:require_pattern] }.
           map { |line| line.sub!(options[:require_pattern], '').split(',') }.
           flatten.
           map { |entry| entry.strip }
    end

    # Returns an associative list that maps source to (unresolved) dependencies
    def process
      sources.map { |source| [source, process_single(source)] }
    end

    class << self
      attr_accessor :comment_pattern, :require_pattern
      private :comment_pattern=, :require_pattern=
    end

    self.comment_pattern = /^\s*\/\/\s*/
    self.require_pattern = /#{self.comment_pattern}#\s*require\s*/
  end
end
