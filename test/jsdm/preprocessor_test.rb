require 'jsdm/preprocessor'
require 'test/unit'

class PreprocessorTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = "test/res/preprocessor/"
  end
  
  def test_process_1
    @root += __method__.to_s
    preprocessor = JSDM::Preprocessor.new Dir["#{@root}/**/*.js"]
    expected = [["#{@root}/a.js", %w(a/* b ./c*.js d)]]
    result = preprocessor.process
    assert_equal expected, result
  end
  
  def test_get_includes_from_complicated
    @root += "test_get_includes_from_complicated"
    preprocessor = JSDM::Preprocessor.new [@root]
    expected = %w(a/* b ./c*.js d)
    assert_equal expected, preprocessor.get_includes_from("#{@root}/a.js")
  end
end
