require 'jsdm'
require 'test/unit'

class PreprocessorTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = "test/res/preprocessor/"
  end
  
  # todo: more thoroughly test parsing by adding more lines to a.js
  def test_get_includes_from
    @root += "test_get_includes_from"
    preprocessor = JSDM::Preprocessor.new [@root]
    expected = %w(a/* b ./c*.js d)
    result = preprocessor.get_includes_from("#{@root}/a.js")
    assert_equal expected, result
  end
  
  def test_get_includes_from_complicated
    @root += "test_get_includes_from_complicated"
    preprocessor = JSDM::Preprocessor.new [@root]
    expected = %w(a/* b ./c*.js d)
    assert_equal expected, preprocessor.get_includes_from("#{@root}/a.js")
  end
end
