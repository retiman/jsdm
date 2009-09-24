require 'jsdm/depth_first_search'
require 'jsdm/natural_loops'

module JSDM
  class DependencyManager
    def initialize(source_root)
      self.source_root = source_root
      self.sources = Dir["#{source_root}/**/*.js"]
      self.dependencies = []
      self.graph = nil
    end

    def add_dependencies(source, includes)
      resolve_entries(includes).each do |dep|
        # make an arc from dep to source
        # in a dfs, dep will be visited before source
        # todo: warn if a file lists itself as a dependency
        dependencies << [dep, source] unless same_file?(dep, source)
      end
    end

    def resolve_entries(entries)
      entries.map { |entry| Dir["#{source_root}/#{entry.strip}"] }.flatten
    end

    def process
      # todo: warn about listing the same dependency twice
      # todo: warn about including the same source twice
      self.sources      = sources.uniq.
                              select { |s| !s.empty? }
      self.dependencies = dependencies.
                              uniq.
                              select { |s| !s.empty? || s.first != s.last }
      self.graph = DirectedGraph.new(sources, dependencies)
      result = dfs(graph)
      loops = loops(graph, result[:back_edges])
      raise "Circular dependency detected: #{loops}" unless loops.empty?
      # return a topological sort of the dependency graph
      result[:sorted] 
    end

    def same_file?(a, b)
      File.expand_path(a) == File.expand_path(b)
    end

    attr_accessor :source_root, :sources, :dependencies, :graph
    private :source_root=, :sources=, :dependencies=, :graph=
  end
end
