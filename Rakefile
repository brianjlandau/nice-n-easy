require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "nice-n-easy"
    gem.summary = %Q{TODO: one-line summary of your gem}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "brian.landau@viget.com"
    gem.homepage = "http://github.com/brianjlandau/nice-n-easy"
    gem.authors = ["Brian Landau"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
    test.rcov_opts = %w[--sort coverage -T --only-uncovered]
  end
rescue LoadError
end

task :test => :check_dependencies

task :default => :test

begin
  require 'rake/rdoctask'
  require 'sdoc'
  Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ""
    title = "Nice-n-Easy #{version} Documentation"

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = title
    rdoc.template = 'direct'
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
    rdoc.main = 'README.md'
    rdoc.options << "-t \"#{title}\""
    rdoc.options << '--fmt shtml'
  end
rescue LoadError
end
