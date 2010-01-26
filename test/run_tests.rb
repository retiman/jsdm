require 'test/unit'

test_dir = File.dirname(File.expand_path(__FILE__))
base_dir = File.expand_path(File.join(test_dir, '..'))

$: << File.join(base_dir, 'lib')

files = Dir[File.join(test_dir, '/**/*_test.rb')]
files.delete_if { |name| name =~ /.*_integration_test.rb$/ }
files.each &method(:require)
