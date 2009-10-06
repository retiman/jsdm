require "jsdm"
require "jsdm/errors"
require "test/unit"

class JSDMTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = "test/res/jsdm/"
  end
  
  def make(dir)
    @root += dir
    jsdm = JSDM.new @root
    jsdm.process!
    jsdm
  end
  
  def test_no_sources
    jsdm = make(__method__.to_s)
    assert_equal [], jsdm.sources
  end
  
  def test_single_source_file
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js"], jsdm.sources
  end

  def test_require_self  
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js"], jsdm.sources
  end
  
  def test_require_missing
    assert_raise JSDM::UnsatisfiableDependencyError do
      jsdm = make(__method__.to_s)
    end
  end

  def test_two_source_files
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js", "#{@root}/b.js"].to_set, jsdm.sources.to_set
  end
  
  def test_one_depends_on_other
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js", "#{@root}/b.js"], jsdm.sources
  end
  
  def test_circular_with_2
    begin
      jsdm = make(__method__.to_s)
    rescue JSDM::CircularDependencyError => e
      expected = [["#{@root}/a.js", "#{@root}/b.js"].to_set].to_set
      assert_equal expected, e.deps
    end
  end

  def test_circular_with_3
    begin
      jsdm = make(__method__.to_s)
    rescue JSDM::CircularDependencyError => e
      expected = [
        ["#{@root}/a.js", "#{@root}/b.js", "#{@root}/c.js"].to_set
      ].to_set
      assert_equal expected.to_set, e.deps
    end
  end
  
  def test_complex_dependency
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js", "#{@root}/b.js", "#{@root}/c.js"], 
                 jsdm.sources
  end

  def test_down_one_dir
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set,
                 jsdm.sources.to_set
  end
  
  def test_down_two_dir
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set,
                 jsdm.sources.to_set
  end
  
  def test_up_one_dir
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set, 
                 jsdm.sources.to_set
  end
  
  def test_up_two_dir
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js", "#{@root}/I/i/b.js"].to_set,
                 jsdm.sources.to_set
  end
  
  def test_glob_matches_self
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/a.js"], jsdm.sorted_sources
  end
  
  def test_circular_with_glob_2
    begin
      jsdm = make(__method__.to_s)
    rescue JSDM::CircularDependencyError => e
      expected = [["#{@root}/a.js", "#{@root}/b.js"].to_set].to_set
      assert_equal expected, e.deps
    end
  end
  
  def test_double_star_with_2
    jsdm = make(__method__.to_s)
    assert_equal ["#{@root}/I/b.js", "#{@root}/a.js"].to_set,
                 jsdm.sources.to_set
  end

  def test_concatenation
    @root += __method__.to_s
    sources = %w(b.js a.js).map { |f| "#{@root}/#{f}" }
    JSDM.concatenate "tmp/test_concatenation", 
    expected = "// test/res/jsdm/test_concatenation/b.js:\n\n" +
               "// test/res/jsdm/test_concatenation/a.js:\n" +
               "// #require b.js\n"
    result = File.new("tmp/test_concatenation").read 
    assert_equal expected, result
  end
end
