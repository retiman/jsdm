class JSDM
  # Very simple class to represent a directed graph using adjacency lists.
  # See http://en.wikipedia.org/wiki/Digraph_(mathematics)
  # See http://en.wikipedia.org/wiki/Adjacency_list
  class DirectedGraph
    attr_accessor :nodes, :arcs
    private :nodes=, :arcs=

    def initialize(nodes, arcs)
      self.nodes = nodes
      self.arcs  = arcs
    end

    # Returns a list of nodes that are in the tail of an arc whose head
    # is the given node.
    def successors(node)
      arcs.select { |a| a.first == node }.map { |a| a.last }
    end
  end
end
