require 'jsdm'
require 'set'
require 'test/unit'

class DependencyManagerTest < Test::Unit::TestCase
  attr_accessor :root
  
  def setup
    @root = "test/res/dependency_manager/"
  end

  def test_resolve_entries
    @root += "test_resolve_entries"
    manager = JSDM::DependencyManager.new(root)
    expected = ["a/b.js",
                "c.js",
                "b/c.js",
                "b/c/d.js",
                "b/c/d/e.js"].map { |f| "#{root}/#{f}" }
    result = manager.resolve_entries("**/*.js")
    assert_equal expected.to_set, result.to_set
  end

  def test_add_and_process_dependencies
    @root += "test_add_and_process_dependencies"
    manager = JSDM::DependencyManager.new(root)
    deps = [["b/c.js",     "a/b.js"],
            ["c.js",       "a/b.js"],
            ["b/c/d.js",   "b/c.js"],
            ["b/c/d/e.js", "a/b.js"],
            ["b/c/d/e.js", "b/c/d.js"],
            ["b/c/d/e.js", "b/c.js"],
            ["b/c/d/e.js", "c.js"]]
    deps.each do |pair|
      source = "#{root}/#{pair.first}"
      includes = pair.last
      manager.add_dependencies(source, includes)
    end
    sorted = manager.process
    sorted.map! { |path| path.sub("#{root}/", "") }
    deps.each do |pair|
      assert_equal pair.reverse, (sorted & pair.reverse)
    end
  end
end
