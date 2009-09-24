require 'jsdm/preprocessor'
require 'jsdm/dependency_manager'
require 'test/unit'

include JSDM

class PreprocessorTest < Test::Unit::TestCase
  def setup
    @preprocessor = Preprocessor.new("res")
  end

  def test_foo
  end
end
