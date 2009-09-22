module JSDM
  def loops?(graph, back_edges)
    loops = []
    back_edges.each do |arc|
      loop  = [arc.first, arc.last]
      stack = []
      stack.push arc.first if arc.first != arc.last
      while !stack.empty?
        u = stack.pop
        graph.arcs.select { |a| a.last == u }.map { a.first }.each do |v|
          if !loop.include?(v)
            loop <<    q
            stack.push q
          end
        end
      end
      loops << loop
    end
    loops.empty?
  end
end
