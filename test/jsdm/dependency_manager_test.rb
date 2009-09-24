require 'jsdm/dependency_manager'
require 'set'
require 'test/unit'

include JSDM

class DependencyManagerTest < Test::Unit::TestCase
  def setup
    @manager = DependencyManager.new("res/dependency_manager")
  end

  def test_resolve_entries
    expected = ["res/dependency_manager/a/b.js",
                "res/dependency_manager/c.js",
                "res/dependency_manager/b/c.js",
                "res/dependency_manager/b/c/d.js",
                "res/dependency_manager/b/c/d/e.js"].to_set
    result = @manager.resolve_entries("**/*.js").to_set
    assert_equal expected, result
  end
end
