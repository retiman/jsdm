require 'jsdm'
require 'jsdm/depth_first_search'
require 'jsdm/directed_graph'
require 'jsdm/natural_loops'
require 'jsdm/errors'

class JSDM
  # This class processes a dependency graph to find the order the source files
  # should be in after a topological sort.
  class DependencyManager
    attr_accessor :sources, :dependencies, :graph

    def initialize(sources)
      self.sources = sources
      self.dependencies = []
      self.graph = nil
    end

    # Add a dependency to the dependency graph.
    def add_dependency(source, dependency)
      unless same_file? dependency, source
        dependencies << [dependency, source]
      end
    end

    # Recursively calculate dependencies for an individual source file.  Uses
    # the acc argument as an accumulator.
    def dependencies_for(source, acc = [])
       ds = dependencies.select { |d| d.last == source }.
                         map { |d| d.first }
       return acc if ds.empty?
       acc = acc | ds
       ds.each { |d| acc = acc | dependencies_for(d, acc) }
       acc
    end

    # Does a topological sort to find the order of dependencies, and checks
    # for any circular dependencies.  The reverse order of visitation in a
    # depth-first search constitutes a topological sort.
    #
    # An algorithm for finding natural loops is used to determine whether or
    # not any circular dependencies exist.  It is slower than simply adding
    # a check to the DepthFirstSearch to see if any nodes have been visited
    # twice, but it allows JSDM to more easily report all circular dependencies
    # rather than just barfing on the first one found.
    #
    # See http://en.wikipedia.org/wiki/Topological_sorting for a more in
    # depth explanation of topological sort.
    def process
      self.sources = sources.uniq.delete_if { |e| e.empty? }
      self.dependencies = dependencies.uniq.delete_if { |e| e.empty? }
      self.graph = DirectedGraph.new sources, dependencies
      result = DepthFirstSearch.dfs graph
      loops = NaturalLoops.find graph, result[:back_edges]
      raise CircularDependencyError.new(loops) unless loops.empty?
      result[:sorted]
    end

    private

    # Test if two files have resolved to the same thing
    def same_file?(a, b)
      File.expand_path(a) == File.expand_path(b)
    end
  end
end
