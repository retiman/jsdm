require 'jsdm'
require 'test/unit'

class JSDMIntegrationTest < Test::Unit::TestCase
  def setup
    @root = "test/res/jsdm/"
  end

  def test_js_check_success
    @root += __method__.to_s
    jsdm = JSDM.new [@root]
    status = jsdm.js_check :output => false
    assert status
  end

  def test_js_check_failure
    @root += __method__.to_s
    jsdm = JSDM.new [@root]
    status = jsdm.js_check :output => false
    assert !status
  end
end
