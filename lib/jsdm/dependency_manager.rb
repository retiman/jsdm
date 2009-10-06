require 'jsdm/depth_first_search'
require 'jsdm/directed_graph'
require 'jsdm/natural_loops'
require 'jsdm/errors'

class JSDM
  class DependencyManager
    attr_accessor :sources, :dependencies, :graph

    def initialize(sources)
      self.sources = sources
      self.dependencies = []
      self.graph = nil
    end

    def add_dependency(source, dependency)
      unless JSDM.same_file? dependency, source
        dependencies << [dependency, source]
      end
    end

    def process
      self.sources = sources.uniq.delete_if { |e| e.empty? }      
      self.dependencies = dependencies.uniq.delete_if { |e| e.empty? }
      self.graph = DirectedGraph.new sources, dependencies
      result = DepthFirstSearch.dfs(graph)
      loops = NaturalLoops.find(graph, result[:back_edges])
      raise CircularDependencyError.new(loops) unless loops.empty?
      result[:sorted] 
    end
  end
end
