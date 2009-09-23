module JSDM
  class Preprocessor
    attr_reader :source_root

    def initialize(source_root)
      self.source_root = source_root
      self.sources = Dir["#{source_root}/**/*.js"]
      self.dependencies = []
    end

    def dependency_graph
      sources.each do |source|
        includes = parse_includes(source)
        resolve_dependencies(includes).each do |dep|
          dependencies << [source, dep]
        end
      end
      DirectedGraph.new(sources, dependecies)
    end

    def parse_includes(file)
      pattern = /^\s*\/\/\s*#include\s*/
      File.new(file).
           readlines.
           take_while { |line| line =~ pattern }.
           map { |line| line.sub(pattern, "").strip }
    end

    def resolve_dependencies(includes)
      deps = []
      includes.each do |inc|
        inc.split(",").each do |entry|
          deps += Dir["#{source_root}/#{entry.strip}"]
        end
      end
      deps 
    end

    private
    attr_writer :source_root
    attr_accessor :nodes
    attr_accessor :arcs
    attr_reader :sources
  end
end
