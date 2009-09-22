class DirectedGraph
  attr_reader :nodes, :arcs

  def initialize(nodes, arcs)
    @nodes = nodes
    @arcs  = arcs
  end
  
  def successors(node)
    arcs.select { |a| a.first == node }.map { |a| a.last }
  end
end
