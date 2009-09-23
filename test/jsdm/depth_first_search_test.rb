require 'jsdm/directed_graph'
require 'jsdm/depth_first_search'
require 'set'
require 'test/unit'

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

  def test_find_tree_edges
    result = dfs(@graph)
    assert_equal @arcs.to_set, result[:tree_edges].to_set
  end

  def test_find_forward_edges
    forward_edges = [[1, 4], [8, 10]]
    @graph = DirectedGraph.new(@nodes, @arcs + forward_edges)
    result = dfs(@graph)
    assert_equal forward_edges.to_set, result[:forward_edges].to_set
  end

  def test_find_back_edges
    back_edges = [[5, 2], [11, 8]]
    @graph = DirectedGraph.new(@nodes, @arcs + back_edges)
    result = dfs(@graph)
    assert_equal back_edges.to_set, result[:back_edges].to_set
  end

  def test_find_cross_edges
    cross_edges = [[10, 5], [9, 6]]
    @graph = DirectedGraph.new(@nodes, @arcs + cross_edges)
    result = dfs(@graph)
    assert_equal cross_edges.to_set, result[:cross_edges].to_set
  end
end
