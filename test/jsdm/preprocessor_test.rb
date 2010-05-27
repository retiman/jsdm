require 'jsdm/preprocessor'
require 'test/unit'

class PreprocessorTest < Test::Unit::TestCase
  attr_accessor :root

  def setup
    @root = File.join('test', 'jsdm', 'preprocessor')
  end

  def test_process_1
    @root = File.join(@root, __method__.to_s)
    sources = Dir["#{@root}/**/*.js"]
    preprocessor = JSDM::Preprocessor.new sources
    expected = [["#{@root}/a.js", %w(a/* b ./c*.js d)]]
    result = preprocessor.process
    assert_equal expected, result
  end

  def test_process_2
    @root = File.join(@root, __method__.to_s)
    sources = Dir["#{@root}/**/*.js"]
    preprocessor = JSDM::Preprocessor.new sources
    expected = [["#{@root}/a.js", %w(a/* b ./c*.js d)]]
    result = preprocessor.process
    assert_equal expected, result
  end
end
