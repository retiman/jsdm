require "jsdm/dependency_resolver"
require "test/unit"

class DependencyManagerTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = "test/res/dependency_resolver/"
  end

  def test_resolver_process
    @root += __method__.to_s
    resolver = JSDM::DependencyResolver.new [@root]
    expected = ["a/b.js",
                "c.js",
                "b/c.js",
                "b/c/d.js",
                "b/c/d/e.js"].map { |f| "#{root}/#{f}" }
    result = resolver.process "**/*.js"
    assert_equal expected.to_set, result.to_set
  end
end
