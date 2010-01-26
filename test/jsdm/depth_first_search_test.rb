require 'jsdm/depth_first_search'
require 'jsdm/directed_graph'
require 'set'
require 'test/unit'

# todo: forward/back/cross edges are not unique across searches
# it depends on node order, so change these tests to only test
# if forward/back/cross edges exist, not what they are
class JSDM::DepthFirstSearchTest < Test::Unit::TestCase
  attr_accessor :graph, :nodes, :arcs

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
    @graph = JSDM::DirectedGraph.new(@nodes, @arcs)
  end

  def test_find_tree_edges
    result = JSDM::DepthFirstSearch.dfs(@graph)
    assert_equal @arcs.to_set, result[:tree_edges].to_set
  end

  def test_find_forward_edges
    forward_edges = [[1, 4], [8, 10]]
    @graph = JSDM::DirectedGraph.new(@nodes, @arcs + forward_edges)
    result = JSDM::DepthFirstSearch.dfs(@graph)
    assert_equal forward_edges.to_set, result[:forward_edges].to_set
  end

  def test_find_back_edges
    back_edges = [[5, 2], [11, 8]]
    @graph = JSDM::DirectedGraph.new(@nodes, @arcs + back_edges)
    result = JSDM::DepthFirstSearch.dfs(@graph)
    assert_equal back_edges.to_set, result[:back_edges].to_set
  end

  def test_find_cross_edges
    cross_edges = [[10, 5], [9, 6]]
    @graph = JSDM::DirectedGraph.new(@nodes, @arcs + cross_edges)
    result = JSDM::DepthFirstSearch.dfs(@graph)
    assert_equal cross_edges.to_set, result[:cross_edges].to_set
  end

  def test_topological_sort
    # make sure the sort happens regardless of node order
    [[11, 6, 1, 7, 3, 8, 5, 9, 4, 10, 2],
     [2, 8, 11, 5, 1, 9, 3, 4, 7, 10, 6],
     [6, 9, 2, 3, 11, 4, 1, 7, 5, 10, 8],
     [8, 4, 6, 1, 2, 7, 11, 5, 3, 10, 9],
     [9, 7, 8, 11, 6, 5, 2, 3, 1, 10, 4],
     [4, 5, 9, 2, 8, 3, 6, 1, 11, 10, 7],
     [7, 3, 4, 6, 9, 1, 8, 11, 2, 10, 5],
     [5, 1, 7, 8, 4, 11, 9, 2, 6, 10, 3],
     [3, 11, 5, 9, 7, 2, 4, 6, 8, 10, 1],
     [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]].each do |nodes|
      @nodes = nodes
      @graph = JSDM::DirectedGraph.new(@nodes, @arcs)
      result = JSDM::DepthFirstSearch.dfs(@graph)
      # intersection via & preserves order
      # arc.first should come before arc.last after a topological sort
      @arcs.each { |arc| assert_equal arc, (result[:sorted] & arc) }
    end
  end
end
