require 'set'
require 'jsdm/dependency_manager'
require 'test/unit'

class DependencyManagerTest < Test::Unit::TestCase
  def setup
    @sources = %w(c.js a/b.js b/c/d/e.js b/c/d.js b/c.js)
    @dependencies = [['b/c.js',     'a/b.js'],
                     ['c.js',       'a/b.js'],
                     ['b/c/d.js',   'b/c.js'],
                     ['b/c/d/e.js', 'a/b.js'],
                     ['b/c/d/e.js', 'b/c/d.js'],
                     ['b/c/d/e.js', 'b/c.js'],
                     ['b/c/d/e.js', 'c.js']]
  end

  def test_process
    manager = JSDM::DependencyManager.new @sources
    @dependencies.each do |arc|
      manager.add_dependency arc.first, arc.last
    end
    sorted = manager.process
    @dependencies.each do |arc|
      assert_equal arc.reverse, (sorted & arc.reverse)
    end
  end

  def test_dependencies_for
    manager = JSDM::DependencyManager.new @sources
    @dependencies.each do |arc|
      manager.add_dependency arc.first, arc.last
    end
    sorted = manager.process
    assert_equal %w(a/b.js b/c/d.js b/c.js c.js).to_set,
                 manager.dependencies_for('b/c/d/e.js').to_set
  end
end
