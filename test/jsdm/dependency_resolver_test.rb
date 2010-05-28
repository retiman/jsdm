require 'jsdm/dependency_resolver'
require 'test/unit'

class DependencyResolverTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = File.join('test', 'jsdm', 'dependency_resolver')
  end

  def test_process_1
    @root = File.join(@root, __method__.to_s)
    load_path = [@root]
    resolver = JSDM::DependencyResolver.new load_path
    expected = [
      File.join(@root, 'a', 'b.js'),
      File.join(@root, 'c.js'),
      File.join(@root, 'b', 'c.js'),
      File.join(@root, 'b', 'c', 'd.js'),
      File.join(@root, 'b', 'c', 'd', 'e.js')
    ].to_set
    result = resolver.process([File.join('**', '*.js')]).to_set
    assert_equal expected, result
  end

  def test_process_2
    @root = File.join(@root, __method__.to_s)
    load_path = [
      File.join(@root, 'path_1'),
      File.join(@root, 'path_2')
    ]
    resolver = JSDM::DependencyResolver.new load_path
    expected = [
      File.join(@root, 'path_2', 'foo', 'bar', 'a.js'),
      File.join(@root, 'path_2', 'foo', 'bar', 'b.js'),
      File.join(@root, 'path_2', 'foo', 'bar', 'c.js')
    ].to_set
    result = resolver.process([File.join('foo', 'bar', '*.js')]).to_set
    assert_equal expected, result
  end
end
