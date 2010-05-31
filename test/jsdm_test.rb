require 'jsdm'
require 'jsdm/errors'
require 'test/unit'

class JSDMTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = File.join('test', 'jsdm')
  end

  def create_jsdm(dir)
    @root = File.join(@root, dir)
    JSDM.new :load_path => @root
  end

  def test_no_sources
    jsdm = create_jsdm(__method__.to_s)
    assert_equal [], jsdm.sources
  end

  def test_no_requires
    jsdm = create_jsdm(__method__.to_s)
    assert_equal [File.join(@root, 'a.js')], jsdm.sources
  end

  def test_require_self
    jsdm = create_jsdm(__method__.to_s)
    assert_equal [File.join(@root, 'a.js')], jsdm.sources
  end

  def test_require_missing
    assert_raise JSDM::UnsatisfiableDependencyError do
      jsdm = create_jsdm(__method__.to_s)
    end
  end

  def test_dependencies
    jsdm = create_jsdm(__method__.to_s)
    expected = %w(a.js b.js c.js).map { |f| File.join(@root, f) }
    assert_equal expected, jsdm.sources
  end

  def test_glob_matches_self
    jsdm = create_jsdm(__method__.to_s)
    assert_equal [File.join(@root, 'a.js')], jsdm.sources
  end

  def test_circular_dependency
    begin
      jsdm = create_jsdm(__method__.to_s)
    rescue JSDM::CircularDependencyError => e
      expected = Set.new([
        Set.new(%w(a.js b.js c.js).map { |f| File.join(@root, f) })
      ])
      assert_equal expected, e.deps
    end
  end

  def test_sources_for
    jsdm = create_jsdm(__method__.to_s)
    expected = %w(a.js b.js c.js d.js).map { |f| File.join(@root, f) }.to_set
    result = jsdm.sources_for(File.join(@root, 'a.js')).to_set
    assert_equal expected, result
  end
end
