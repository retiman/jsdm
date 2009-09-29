class JSDM
  class DirectedGraph
    attr_accessor :nodes, :arcs
    private :nodes=, :arcs=

    def initialize(nodes, arcs)
      self.nodes = nodes
      self.arcs  = arcs
    end
    
    def successors(node)
      arcs.select { |a| a.first == node }.map { |a| a.last }
    end
  end
end
