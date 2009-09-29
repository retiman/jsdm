require 'jsdm'
require 'test/unit'

class JsdmTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = "test/res/jsdm/"
  end
  
  def test_no_sources
    @root += "test_no_sources"
    jsdm = Jsdm.new [@root]
    assert_equal [], jsdm.sort
  end
  
  def test_single_source_file
    @root += "test_single_source_file"
    jsdm = Jsdm.new [@root]
    assert_equal ["#{@root}/a.js"], jsdm.sort
  end

  def test_require_self  
    @root += "test_require_self"
    jsdm = Jsdm.new [@root]
    assert_equal ["#{@root}/a.js"], jsdm.sort
  end
  
  def test_require_missing
    @root += "test_require_missing"
    assert_raise UnsatisfiableDependencyError do
      jsdm = Jsdm.new(@root)
      jsdm.sort
    end
  end

  def test_two_source_files
    @root += "test_two_source_files"
    jsdm = Jsdm.new [@root]
    sorted = jsdm.sort
    assert_equal ["#{@root}/a.js", "#{@root}/b.js"].to_set, sorted.to_set
  end
  
  def test_one_depends_on_other
    @root += "test_one_depends_on_other"
    jsdm = Jsdm.new [@root]
    sorted = jsdm.sort
    assert_equal ["#{@root}/a.js", "#{@root}/b.js"].to_set, sorted.to_set
  end
  
  def test_circular_with_2
    @root += "test_circular_with_2"
    begin
  	  jsdm = Jsdm.new [@root]
      jsdm.sort
    rescue CircularDependencyError => e
      expected = [["#{@root}/a.js", "#{@root}/b.js"].to_set].to_set
      assert_equal expected, e.deps
    end
  end
  
  def test_complex_dependency
  	@root += "test_complex_dependency"
    jsdm = Jsdm.new [@root]
    sorted = jsdm.sort
    assert_equal ["#{@root}/a.js", "#{@root}/b.js", "#{@root}/c.js"], sorted
   end
  
  def test_circular_with_3
    @root += "test_circular_with_3"
    begin
      jsdm = Jsdm.new [@root]
      jsdm.sort
    rescue CircularDependencyError => e
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
    jsdm = Jsdm.new [@root]
    sorted = jsdm.sort
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set, sorted.to_set
  end
  
  def test_down_two_dir
    @root += "test_down_two_dir"
    jsdm = Jsdm.new(root)
    sorted = jsdm.sort
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set, sorted.to_set
  end
  
  def test_up_one_dir
    @root += "test_up_one_dir"
    jsdm = Jsdm.new [@root]
    sorted = jsdm.sort
    assert_equal ["#{@root}/a.js", "#{@root}/I/b.js"].to_set, sorted.to_set
  end
  
  def test_up_two_dir
    @root += "test_up_two_dir"
    jsdm = Jsdm.new [@root]
    sorted = jsdm.sort
    assert_equal ["#{@root}/a.js", "#{@root}/I/i/b.js"].to_set, sorted.to_set
  end
  
  def test_glob_matches_self
    @root += "test_glob_matches_self"
    jsdm = Jsdm.new [@root]
    assert_equal ["#{@root}/a.js"], jsdm.sort
  end
  
  def test_circular_with_glob_2
    @root += "test_circular_with_glob_2"
    begin
      jsdm = Jsdm.new [@root]
      jsdm.sort
    rescue CircularDependencyError => e
      expected = [["#{@root}/a.js", "#{@root}/b.js"].to_set].to_set
    	assert_equal expected, e.deps
    end
  end
  
  def test_double_star_with_2
    @root += "test_double_star_with_2"
    jsdm = Jsdm.new [@root]
    sorted = jsdm.sort
    assert_equal ["#{@root}/I/b.js", "#{@root}/a.js"].to_set, sorted.to_set
  end
end
