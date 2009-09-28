module JSDM
  class UnsatisfiedDependencyError < StandardError
    attr_accessor :source, :entry, :dep
    private :source=, :entry=, :dep=

    def initialize(source, entry, dep)
      msg = "File #{source} required #{dep} via the following line:\n"
          + "  #{entry}\n"
          + "  but the required file could not be found."
      self.source = source
      self.entry = entry
      self.dep = dep
      super(msg)
    end
  end
end
