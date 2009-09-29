class JSDM
  class UnsatisfiableDependencyError < StandardError
    attr_accessor :source, :dep
    private :source=, :dep=

    def initialize(source, dep)
      msg = "File #{source} has unsatisfiable dependency:\n" +
            "  #{dep}"
      self.source = source
      self.dep = dep
      super(msg)
    end
  end
end
