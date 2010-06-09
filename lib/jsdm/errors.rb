require 'pp'

class JSDM
  # This error is raised if a set of files (or if multiple sets of files) are
  # in a circular dependency.  JSDM will report them all, so deps will be a
  # set of sets.
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

  # Used internally to indicate that a file could not be found; this error will
  # not be exposed to the user.  This error eventually gets wrapped in a
  # UnsatisfiableDependencyError.
  class FileNotFoundError < StandardError
    attr_accessor :file
    private :file=

    def initialize(file)
      super("File not found: #{file}")
      self.file = file
    end
  end

  # This error is raised if a file could not be found.  This error includes
  # information about the dependency that couldn't be found, and the source
  # that asked for that dependency.
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

