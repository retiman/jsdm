module JSDM
  class DepthFirstSearch
    def initialize(graph)
      @graph            = graph
      @discovered_times = Hash.new { |h, k| h[k] = 0 }
      @finished_times   = Hash.new { |h, k| h[k] = 0 }
      @node_colors      = Hash.new { |h, k| h[k] = :white }
      @edge_colors      = Hash.new { |h, k| h[k] = [] }
      @predecessors     = Hash.new
      @sorted           = []
      @time             = 0
      graph.each do |k|
        [@discovered_times, @finished_times, @node_colors].each { |h| h[k] }
      end
      [:white, :black, :gray].each { |color| @edge_colors[color] }
    end
    
    def result
      compute()
      result = Hash.new { |h, k| h[k] = instance_variable_get("@#{k.to_s}") }
      result.merge! {
        :tree_edges       => @edge_colors[:white],
        :forward_edges    => @edge_colors[:black].select { |e|
                               t = discovered_times[e.first]
                               u = discovered_times[e.last]
                               t < u
                             },
        :cross_edges      => @edge_colors[:black].select { |e|
                               t = discovered_times[e.first]
                               u = discovered_times[e.last]
                               t > u
                             },
        :back_edges       => @edge_colors[:gray]
      }
    end

    def compute
      @graph.nodes.each do |u|
        visit(u) if @node_colors[u] == :white
      end
    end

    def visit(u)
      @time += 1
      @discovered_times[u] = @time
      @node_colors[u]      = :gray
      @graph.successors(u).each do |v|
        case @node_colors[v]
        when :white
          @edge_colors[:white] << [u, v]
          @predecessors[v]     = u
          visit(v)
        when :gray
          @edge_colors[:gray]  << [u, v]
        else
          @edge_colors[:black] << [u, v]
        end
      end
      @node_colors[u]      = :black
      @finished_times[u]   = @time
      @sorted              = [u] + @sorted
      @time += 1
    end
  end
  
  def dfs(graph)
    search = DepthFirstSearch.new(graph)
    search.result
  end
end
