require 'set'

class JSDM
  # This class calculates the natural loops in a directed graph, given the
  # back edges.
  #
  # Implements the algorithm found on page 192 of Advanced Compiler Design and
  # Implementation by Steven S. Muchnick.
  module NaturalLoops
    extend self

    # Returns a set of "loops" (which are in turn a set of nodes), given a
    # DirectedGraph and the back edges found from a DepthFirstSearch, if any
    # exist.
    def find(graph, back_edges)
      loops = Set.new
      back_edges.each do |arc|
        l = [arc.first, arc.last]
        stack = []
        stack.push arc.first if arc.first != arc.last
        while !stack.empty?
          u = stack.pop
          neighbors = graph.arcs.
                            select { |a| a.last == u }.
                            map { |a| a.first }
          neighbors.each do |v|
            next if l.include? v
            l << v
            stack.push v
          end
        end
        loops << l.to_set
      end
      loops
    end
  end
end
