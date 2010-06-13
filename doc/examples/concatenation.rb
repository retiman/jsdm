#!/usr/bin/env ruby
require 'jsdm'
require 'pp'

# Concatenates all the JavaScript files together
load_path = %w(foo bar baz).map do |p|
  File.join(File.dirname(__FILE__), 'js', p)
end
jsdm = JSDM.new :load_path => load_path
jsdm.sources.each do |source|
  puts "// File: #{source}"
  puts File.read(source)
end
