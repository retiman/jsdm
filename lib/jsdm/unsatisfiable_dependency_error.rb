module JSDM
  class UnsatisfiableDependencyError < StandardError
    attr_accessor :source, :dep
    private :source=, :dep=

    def initialize(source, dep)
      msg = "File #{source}\n"
          + "  required #{dep}"
          + "  but the required file could not be found."
      self.source = source
      self.dep = dep
      super(msg)
    end
  end
end
