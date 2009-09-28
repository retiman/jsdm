require 'jsdm/circular_dependency_error'
require 'jsdm/dependency_manager'
require 'jsdm/file_not_found_error'
require 'jsdm/preprocessor'
require 'test/unit'

include JSDM

# pattern testing
# these tests define the behavior of fundamental dependency patterns;
# there is no emergent behavior for greater numbers of files.
# the tests are ordered by complexity.
# todo: add tests with additional load paths
class PreprocessorTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = "test/res/preprocessor/"
  end
  
  def test_check_load_path_exists
    @root += "test_check_load_path"
    load_path = %w(path_1 path_2 path_3).map { |path| "#{@root}/#{path}" }
    assert_nothing_raised do
      Preprocessor.new load_path
    end
  end
  
  def test_check_load_path_doesnt_exist
    @root += "test_check_load_path"
    load_path = %w(path_1 path_2 path_3 path_4).map { |path| "#{@root}/#{path}" }
    assert_raise FileNotFoundError do
      Preprocessor.new load_path
    end
  end  

  # todo: more thoroughly test parsing by adding more lines to a.js
  def test_get_includes_from
    @root += "test_get_includes_from"
    preprocessor = Preprocessor.new [@root]
    expected = %w(a/* b ./c*.js d)
    result = preprocessor.get_includes_from("#{@root}/a.js")
    assert_equal expected, result
  end
  
  def test_get_includes_from_complicated
    @root += "test_get_includes_from_complicated"
    preprocessor = Preprocessor.new [@root]
    expected = %w(a/* b ./c*.js d)
    assert_equal expected, preprocessor.get_includes_from("#{@root}/a.js")
  end
end
