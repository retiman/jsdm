require 'jsdm/preprocessor'
require 'jsdm/dependency_manager'
require 'test/unit'

include JSDM

class PreprocessorTest < Test::Unit::TestCase
  def setup
    @preprocessor = Preprocessor.new("res")
  end

  def test_get_includes
    expected = ["a/*", "b", "./c*.js", "d"]
    result = @preprocessor.get_includes("res/preprocessor.js")
    assert_equal expected, result
  end
end
