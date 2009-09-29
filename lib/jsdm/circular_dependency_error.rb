class JSDM
  class CircularDependencyError < StandardError
    attr_accessor :deps
    private :deps=

    def initialize(deps)
      msg = "The following sets of files are involved in circular " +
            "dependencies: #{deps.inspect}"
      self.deps = deps
      super(msg)
    end
  end
end
