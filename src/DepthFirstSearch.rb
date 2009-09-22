module JSDM
  class DepthFirstSearch
    def initialize(graph)
      @graph            = graph
      @discovered_times = Hash[graph.nodes.map { |n| [n, 0] }]
      @finished_times   = Hash[graph.nodes.map { |n| [n, 0] }]
      @node_colors      = Hash[graph.nodes.map { |n| [n, :white] }]
      @edge_colors      = { :white => [], :black => [], :gray => [] }
      @predecessors     = Hash[graph.nodes.map { |n| [n, nil] }]
      @sorted           = []
      @time             = 0
    end
    
    def result
      compute()
      return Hash.new({
        :graph            => @graph,
        :discovered_times => @discovered_times,
        :finished_times   => @finished_times,
        :node_colors      => @node_colors,
        :edge_colors      => @edge_colors,
        :predecessors     => @predecessors,
        :sorted           => @sorted,
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
      })
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
