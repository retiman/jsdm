require 'test/unit'
require 'jsdm/directed_graph'
require 'jsdm/depth_first_search'
include JSDM

class DepthFirstSearchTest < Test::Unit::TestCase
  def setup
    #         Graph G
    #            1
    #           /|\
    #          2 7 8
    #         /|   |\
    #        3 6   9 12
    #       /|     |\
    #      4 5     | \
    #              10 11
    @nodes = 1.upto(11).to_a
    @arcs  = [[1, 2],
             [1, 7],
             [1, 8],
             [2, 3],
             [2, 6],
             [3, 4],
             [3, 5],
             [8, 9],
             [8, 12],
             [9, 10],
             [9, 11]]
    @graph = DirectedGraph.new(@nodes, @arcs)
  end

  def test_forward_edges
    forward_edges = [[1, 4], [8, 10]]
    @graph = DirectedGraph.new(@nodes, @arcs + forward_edges)
    result = dfs(@graph)
    assert_equal forward_edges, result[:forward_edges]
  end
end
