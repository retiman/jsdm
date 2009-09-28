module JSDM
  class FileNotFoundError < StandardError
    attr_accessor :file
    private :file=

    def initialize(file)
      super("File not found: #{file}")
      self.file = file
    end
  end
end
