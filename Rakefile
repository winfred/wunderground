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
  gem.name = "wunderground_ruby"
  gem.homepage = "http://github.com/wnadeau/wunderground_ruby"
  gem.license = "MIT"
  gem.summary = %Q{A simple ruby API wrapper for interacting with the Wunderground API}
  gem.description = %Q{A simple ruby API wrapper for interacting with the Wunderground API}
  gem.email = "winfred.nadeau@gmail.com"
  gem.authors = ["Winfred Nadeau"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  gem.add_runtime_dependency 'httparty', '> 0.6.0'
  gem.add_runtime_dependency 'json', '> 1.4.0'
  gem.add_development_dependency 'shoulda', '> 0.0.0'
  gem.add_development_dependency 'mocha', '> 0.9.11'
  gem.add_development_dependency 'simplecov', '> 0'
  #gem.add_development_dependency 'rspec', '> 1.2.3'
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