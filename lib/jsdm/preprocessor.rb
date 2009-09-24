module JSDM
  class Preprocessor
    def initialize(source_root)
      self.pattern = /^\s*\/\/\s*#include\s*/
      self.source_root = source_root
      self.manager = DependencyManager.new(source_root)
    end

    def process
      Dir["#{source_root}/**/*.js"].each do |source|
        includes = get_includes(source)
        manager.add_dependencies(source, includes)
      end
      manager.process
    end

    def get_includes(file)
      File.new(file).
           readlines.
           take_while { |line| line =~ pattern }.
           map { |line| line.sub!(pattern, "").split(",") }.
           flatten.
           map { |entry| entry.strip }
    end

    attr_accessor :source_root, :pattern
    private :source_root=, :pattern=
    private
    attr_accessor :manager
  end
end
