require 'test/unit'

test_dir = File.dirname(File.expand_path(__FILE__))
base_dir = File.expand_path(File.join(test_dir, ".."))

$: << File.join(base_dir, "lib")

Dir[File.join(test_dir, "/**/*_integration_test.rb")].each &method(:require)
