require 'jsdm/spidermonkey'
require 'test/unit'

class SpidermonkeyIntegrationTest < Test::Unit::TestCase
  def setup
    @root = "test/res/spidermonkey/"
  end

  def test_js_check_success
    @root += __method__.to_s
    sources = %w(a.js b.js c.js).map { |f| "#{@root}/#{f}" }
    status = Spidermonkey.check sources, :output => false
    assert status
  end

  def test_js_check_failure
    @root += __method__.to_s
    sources = %w(a.js b.js c.js).map { |f| "#{@root}/#{f}" }
    status = Spidermonkey.check sources, :output => false
    assert !status
  end
end
