require 'jsdm'
require 'jsdm/depth_first_search'
require 'jsdm/directed_graph'
require 'jsdm/natural_loops'
require 'jsdm/errors'
require 'pp'

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

    def dependencies_of(source, acc = [])
       ds = dependencies.select { |d| d.last == source }.
                         map { |d| d.first }
       return acc if ds.empty?
       acc = acc | ds
       ds.each { |d| acc = acc | dependencies_of(d, acc) }
       acc
    end

    def process
      self.sources = sources.uniq.delete_if { |e| e.empty? }
      self.dependencies = dependencies.uniq.delete_if { |e| e.empty? }
      self.graph = DirectedGraph.new sources, dependencies
      result = DepthFirstSearch.dfs graph
      loops = NaturalLoops.find graph, result[:back_edges]
      raise CircularDependencyError.new(loops) unless loops.empty?
      result[:sorted]
    end
  end
end
