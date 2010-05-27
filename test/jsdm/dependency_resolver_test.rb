require 'jsdm/dependency_resolver'
require 'test/unit'

class DependencyResolverTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = File.join('test', 'jsdm', 'dependency_resolver')
  end

  def test_process_1
    @root = File.join(@root, __method__.to_s)
    resolver = JSDM::DependencyResolver.new [@root]
    expected = ['a/b.js',
                'c.js',
                'b/c.js',
                'b/c/d.js',
                'b/c/d/e.js'].map { |f| "#{@root}/#{f}" }.
                              to_set
    result = resolver.process('**/*.js').to_set
    assert_equal expected, result
  end

  def test_process_2
    @root = File.join(@root, __method__.to_s)
    load_path = ["#{@root}/path_1", "#{@root}/path_2"]
    resolver = JSDM::DependencyResolver.new load_path
    expected = ['foo/bar/a.js',
                'foo/bar/b.js',
                'foo/bar/c.js'].map { |f| "#{@root}/path_2/#{f}" }.
                                to_set
    result = resolver.process('foo/bar/*.js').to_set
    assert_equal expected, result
  end
end
