require 'jsdm/depth_first_search'
require 'jsdm/natural_loops'

module JSDM
  class DependencyManager
    def initialize(source_root)
      self.source_root = source_root
      self.sources = []
      self.dependencies = []
    end

    def add_dependencies(source, includes)
      resolve_entries(includes).each do |dep|
        # make an arc from dep to source
        # in a dfs, dep will be visited before source
        # todo: warn if a file lists itself as a dependency
        dependencies << [dep, source] unless same(dep, source)
      end
    end

    def resolve_entries(entries)
      entries.map { |entry| Dir["#{source_root}/#{entry.strip}"] }.flatten
    end

    def process
      # todo: warn about listing the same dependency twice
      # todo: warn about including the same source twice
      self.sources = sources.uniq.select { |s| !s.empty? }
      self.dependencies = dependencies.uniq.select { |s| s.empty? || s.first == s.last }
      graph = DirectedGraph.new(sources, dependencies)
      result = dfs(graph)
      loops = loops(graph, result[:back_edges])
      raise "Circular dependency detected: #{loops}" unless loops.empty?
      # return a topological sort of the dependency graph
      result[:sorted] 
    end

    def same_file?(a, b)
      File.expand_path(a) == File.expand_path(b)
    end

    private
    attr_accessor :source_root
    attr_accessor :sources
    attr_accessor :dependencies
  end
end
