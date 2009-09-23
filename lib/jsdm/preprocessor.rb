module JSDM
  class Preprocessor
    def initialize(source_root)
      self.source_root = source_root
      self.manager = DependencyManagemer.new
    end

    def process
      Dir["#{source_root}/**/*.js"].each do |source|
        includes = parse_includes(source)
        manager.add_dependencies(source, includes)
      end
      manager.process
    end

    def parse_includes(file)
      pattern = /^\s*\/\/\s*#include\s*/
      File.new(file).
           readlines.
           take_while { |line| line =~ pattern }.
           map { |line| line.sub(pattern, "").strip }
    end

    private
    attr_accessor :source_root
  end
end
