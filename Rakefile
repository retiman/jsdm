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
  s.version      = "0.1.0"
  s.summary      = "Javascript dependency manager"
  s.description  = "Use #require statements to declare dependencies"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_bz2 = true
end

desc "Clean the build"
task :clean do
  FileUtils.rm_rf "pkg"
end

desc "Run all tests (no arg), or single test (with arg)"
task :test, :name do |t, args|
  opts = args.name.nil? ? "" : "-n test_#{args.name}"
  cmd = "ruby test/run.rb #{opts}"
  puts cmd
  system cmd
end
  
task :default => :package
