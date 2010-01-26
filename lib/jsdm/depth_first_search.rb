require 'set'

class JSDM
  class DepthFirstSearch
    def initialize(graph)
      self.graph            = graph
      self.discovered_times = Hash.new { |h, k| h[k] = 0 }
      self.finished_times   = Hash.new { |h, k| h[k] = 0 }
      self.node_colors      = Hash.new { |h, k| h[k] = :white }
      self.edge_colors      = Hash.new { |h, k| h[k] = [] }
      self.predecessors     = Hash.new
      self.sorted           = []
      self.time             = 0
    end

    def process
      graph.nodes.each { |u| visit(u) if node_colors[u] == :white }
      return {
        :discovered_times => discovered_times,
        :finished_times   => finished_times,
        :node_colors      => node_colors,
        :edge_colors      => edge_colors,
        :predecessors     => predecessors,
        :sorted           => sorted,
        :tree_edges       => edge_colors[:white],
        :forward_edges    => edge_colors[:black].select do |e|
                               t = discovered_times[e.first]
                               u = discovered_times[e.last]
                               t < u
                             end,
        :cross_edges      => edge_colors[:black].select do |e|
                               t = discovered_times[e.first]
                               u = discovered_times[e.last]
                               t > u
                             end,
        :back_edges       => edge_colors[:gray]
      }
    end

    def visit(u)
      self.time += 1
      discovered_times[u] = time
      node_colors[u] = :gray
      graph.successors(u).each do |v|
        case node_colors[v]
        when :white
          edge_colors[:white] << [u, v]
          predecessors[v] = u
          visit(v)
        when :gray
          edge_colors[:gray]  << [u, v]
        else
          edge_colors[:black] << [u, v]
        end
      end
      node_colors[u] = :black
      finished_times[u] = time
      sorted.unshift u
      self.time += 1
    end

    def self.dfs(graph)
      search = DepthFirstSearch.new(graph)
      search.process
    end

    protected
    attr_accessor :graph,
                  :discovered_times,
                  :finished_times,
                  :node_colors,
                  :edge_colors,
                  :predecessors,
                  :sorted,
                  :time
  end
end
