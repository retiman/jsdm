module JSDM
  class DirectedGraph
    def initialize(nodes, arcs)
      self.nodes = nodes
      self.arcs  = arcs
    end
    
    def successors(node)
      arcs.select { |a| a.first == node }.map { |a| a.last }
    end

    private
    attr_reader :nodes
    attr_reader :arcs
  end
end
