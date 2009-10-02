require 'fileutils'
require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'

spec = Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = "jsdm"
  s.author       = "Min Huang"
  s.email        = "min.huang@alumni.usc.edu"
  s.files        = Dir["lib/**/*"] + %w(Rakefile)
  s.require_path = "lib"
  s.has_rdoc     = true
  s.homepage     = "http://www.borderstylo.com/#{s.name}"
  s.version      = "0.1.20"
  s.summary      = "Javascript dependency manager"
  s.description  = "Use #require statements to declare dependencies"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_bz2 = true
end

desc "Clean the build"
task :clean do
  FileUtils.rm_rf "pkg", :verbose => true
  FileUtils.rm_rf "tmp", :verbose => true
end

desc "Run all tests (unit and integration)"
task :test => [:unit_test, :integration_test]

desc "Run unit tests (no arg), or single test (with arg)"
task :unit_test, :name do |t, args|
  FileUtils.mkdir "tmp", :verbose => true if !File.directory? "tmp"
  opts = args.name.nil? ? "" : "-n test_#{args.name}"
  cmd = "ruby test/run_unit_tests.rb #{opts}"
  puts cmd
  system cmd
end

desc "Run integration tests (no arg), or single test (with arg)"
task :integration_test, :name do |t, args|
  FileUtils.mkdir "tmp", :verbose => true if !File.directory? "tmp"
  opts = args.name.nil? ? "" : "-n test_#{args.name}"
  cmd = "ruby test/run_integration_tests.rb #{opts}"
  puts cmd
  system cmd
end
 
task :default => :package
