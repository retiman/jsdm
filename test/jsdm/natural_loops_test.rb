require "jsdm/directed_graph"
require "jsdm/natural_loops"
require "set"
require "test/unit"

class NaturalLoopsTest < Test::Unit::TestCase
  attr_accessor :nodes, :arcs

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
  end

  def test_find_no_loops
    graph = JSDM::DirectedGraph.new(@nodes, @arcs)
    assert_equal [].to_set, JSDM::NaturalLoops.find(graph, [])
  end

  def test_find_loops
    @arcs += [[4, 1], [12, 1]]
    graph = JSDM::DirectedGraph.new(@nodes, @arcs)
    back_edges = JSDM::DepthFirstSearch.dfs(graph)[:back_edges]
    assert_equal [[1, 2, 3, 4].to_set, 
                  [1, 8, 12].to_set,
                 ].to_set,
                 JSDM::NaturalLoops.find(graph, back_edges)
  end
end
