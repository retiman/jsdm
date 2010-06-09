require 'fileutils'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'

spec = Gem::Specification.new do |s|
  s.platform          = Gem::Platform::RUBY
  s.name              = 'jsdm'
  s.author            = 'Min Huang'
  s.email             = 'min.huang@alumni.usc.edu'
  s.files             = Dir["{lib,doc,bin,ext}/**/*"].delete_if { |f|
                          /\/rdoc(\/|$)/i.match f
                        } + %w(Rakefile README.rdoc)
  s.require_path      = 'lib'
  s.has_rdoc          = true
  s.rubyforge_project = 'jsdm'
  s.homepage          = 'http://www.github.com/retiman/jsdm'
  s.version           = '0.4.2'
  s.summary           = 'Javascript dependency manager'
  s.description       = <<-EOF
    Use #require statements to declare dependencies in JavaScript
  EOF
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar_bz2 = true
end

Rake::RDocTask.new(:doc) do |t|
  t.title = 'JSDM'
  t.main = 'README.rdoc'
  t.rdoc_files.include('lib/**/*.rb', 'doc/*', 'README.rdoc')
  t.rdoc_dir = 'doc/rdoc'
end

desc 'Run tests (no arg), or single test (with arg)'
task :test, :name do |t, args|
  opts = args.name.nil? ? '' : "-n test_#{args.name}"
  cmd = "ruby test/run_tests.rb #{opts}"
  puts cmd
  system(cmd) || raise('Build error')
end

task :install => :package do
  g = "pkg/#{spec.name}-#{spec.version}.gem"
  system "sudo gem install -l #{g}"
end

task :default => :package
