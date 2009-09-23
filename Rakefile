require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.platform     = Gem::Platform::RUBY
  s.name         = "jsdm"
  s.author       = "Min Huang"
  s.email        = "min.huang@alumni.usc.edu"
  s.files        = Dir["src/**/*"] + %w(Rakefile)
  s.require_path = "src"
  s.has_rdoc     = false
  s.summary      = "Dependency management done right"
  s.version      = "0.0.1"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_bz2 = true
end

desc "Run all specs"
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files    = FileList["test/**/*_spec.rb"]
end
  
task :default => :package
