require 'jsdm/dependency_manager'
require 'set'
require 'test/unit'

include JSDM

class DependencyManagerTest < Test::Unit::TestCase
  def setup
    @manager = DependencyManager.new("res/dependency_manager")
  end

  def test_resolve_entries
    expected = ["a/b.js",
                "c.js",
                "b/c.js",
                "b/c/d.js",
                "b/c/d/e.js"].map { |f| "#{@manager.source_root}/#{f}" }
    result = @manager.resolve_entries("**/*.js")
    assert_equal expected.to_set, result.to_set
  end

  def test_add_and_process_dependencies
    [["b/c.js", "a/b.js"],
     ["c.js", "a/b.js"],
     ["b/c/d.js", "b/c.js"],
     ["b/c/d/e.js", "a/b.js"],
     ["b/c/d/e.js", "b/c/*.js"],
     ["b/c/d/e.js", "b/*.js"],
     ["b/c/d/e.js", "*.js"]].each do |pair|
      source = "#{@manager.source_root}/#{pair.first}"
      includes = pair.last
      @manager.add_dependencies(source, includes)
    end
    expected = %w(res/dependency_manager/a/b.js
                  res/dependency_manager/c.js
                  res/dependency_manager/b/c.js
                  res/dependency_manager/b/c/d.js
                  res/dependency_manager/b/c/d/e.js)
    result = @manager.process
    assert_equal expected, result
  end
end
