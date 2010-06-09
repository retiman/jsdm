require 'set'

class JSDM
  module NaturalLoops
    extend self

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
