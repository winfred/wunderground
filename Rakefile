require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "wunderground"
  gem.homepage = "http://github.com/wnadeau/wunderground_ruby"
  gem.license = "MIT"
  gem.summary = %Q{A simple ruby API wrapper for interacting with the Wunderground API}
  gem.description = %Q{A simple ruby API wrapper for interacting with the Wunderground API}
  gem.email = "winfred.nadeau@gmail.com"
  gem.authors = ["Winfred Nadeau"]
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Wunderground #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
desc "Open an irb session preloaded with this library"
task :console do
  exec "irb -rubygems -I lib -r wunderground"
end