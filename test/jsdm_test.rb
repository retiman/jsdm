require 'jsdm'
require 'test/unit'

class JSDMTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = "test/res/jsdm/"
  end
  
  def test_no_sources
    @root += "test_no_sources"
    jsdm = JSDM.new [@root]
    assert_equal [], jsdm.sorted_sources
  end
  
  def test_single_source_file
    @root += "test_single_source_file"
    jsdm = JSDM.new [@root]
    assert_equal ["#{@root}/a.js"], jsdm.sorted_sources
  end

  def test_require_self  
    @root += "test_require_self"
    jsdm = JSDM.new [@root]
    assert_equal ["#{@root}/a.js"], jsdm.sorted_sources
  end
  
  def test_require_missing
    @root += "test_require_missing"
    assert_raise JSDM::UnsatisfiableDependencyError do
      jsdm = JSDM.new(@root)
      jsdm.sorted_sources
    end
  end

  def test_two_source_files
    @root += "test_two_source_files"
    jsdm = JSDM.new [@root]
    sorted = jsdm.sorted_sources
    assert_equal ["#{@root}/a.js", "#{@root}/b.js"].to_set, sorted.to_set
  end
  
  def test_one_depends_on_other
    @root += "test_one_depends_on_other"
    jsdm = JSDM.new [@root]
    sorted = jsdm.sorted_sources
    assert_equal ["#{@root}/a.js", "#{@root}/b.js"].to_set, sorted.to_set
  end
  
  def test_circular_with_2
    @root += "test_circular_with_2"
    begin
      jsdm = JSDM.new [@root]
      jsdm.sorted_sources
    rescue JSDM::CircularDependencyError => e
      expected = [["#{@root}/a.js", "#{@root}/b.js"].to_set].to_set
      assert_equal expected, e.deps
    end
  end
  
  def test_complex_dependency
    @root += "test_complex_dependency"
    jsdm = JSDM.new [@root]
    sorted = jsdm.sorted_sources
    assert_equal ["#{@root}/a.js", "#{@root}/b.js", "#{@root}/c.js"], sorted
   end
  
  def test_circular_with_3
    @root += "test_circular_with_3"
    begin
      jsdm = JSDM.new [@root]
      jsdm.sorted_sources
    rescue JSDM::CircularDependencyError => e
      expected = [
        ["#{@root}/a.js", "#{@root}/b.js", "#{@root}/c.js"].to_set
      ].to_set
      assert_equal expected.to_set, e.deps
    end
  end
  
  # directory testing
  # todo: up one directory, up two directories, down two directories
  def test_down_one_dir
    @root += "test_down_one_dir"
    jsdm = JSDM.new [@root]
    sorted = jsdm.sorted_sources
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set, sorted.to_set
  end
  
  def test_down_two_dir
    @root += "test_down_two_dir"
    jsdm = JSDM.new(root)
    sorted = jsdm.sorted_sources
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set, sorted.to_set
  end
  
  def test_up_one_dir
    @root += "test_up_one_dir"
    jsdm = JSDM.new [@root]
    sorted = jsdm.sorted_sources
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set, sorted.to_set
  end
  
  def test_up_two_dir
    @root += "test_up_two_dir"
    jsdm = JSDM.new [@root]
    sorted = jsdm.sorted_sources
    assert_equal ["#{@root}/a.js", "#{@root}/I/i/b.js"].to_set, sorted.to_set
  end
  
  def test_glob_matches_self
    @root += "test_glob_matches_self"
    jsdm = JSDM.new [@root]
    assert_equal ["#{@root}/a.js"], jsdm.sorted_sources
  end
  
  def test_circular_with_glob_2
    @root += "test_circular_with_glob_2"
    begin
      jsdm = JSDM.new [@root]
      jsdm.sorted_sources
    rescue JSDM::CircularDependencyError => e
      expected = [["#{@root}/a.js", "#{@root}/b.js"].to_set].to_set
      assert_equal expected, e.deps
    end
  end
  
  def test_double_star_with_2
    @root += "test_double_star_with_2"
    jsdm = JSDM.new [@root]
    sorted = jsdm.sorted_sources
    assert_equal ["#{@root}/I/b.js", "#{@root}/a.js"].to_set, sorted.to_set
  end

  def test_concatenation
    @root += "test_concatenation"
    jsdm = JSDM.new [@root]
    jsdm.concatenate "tmp/test_concatenation"
    expected = "// test/res/jsdm/test_concatenation/b.js:\n\n" +
               "// test/res/jsdm/test_concatenation/a.js:\n" +
               "// #require b.js\n"
    result = File.new("tmp/test_concatenation").read 
    assert_equal expected, result
  end
end
