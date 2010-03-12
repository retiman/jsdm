require 'pp'

class JSDM
  class CircularDependencyError < StandardError
    attr_accessor :deps
    private :deps=

    def initialize(deps)
      msg = 'The following sets of files are involved in circular ' +
            'dependencies: '
      s = ''
      deps.each { |d| msg += PP.pp(d, s) }
      self.deps = deps
      super(msg)
    end
  end

  class FileNotFoundError < StandardError
    attr_accessor :file
    private :file=

    def initialize(file)
      super("File not found: #{file}")
      self.file = file
    end
  end

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

