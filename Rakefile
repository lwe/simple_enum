require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the simple_enum plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the simple_enum plugin (results in doc/).'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'SimpleEnum'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('LICENCE');
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    require File.join(File.dirname(__FILE__), 'lib', 'simple_enum')
    
    gemspec.name = "simple_enum"
    gemspec.version = SimpleEnum::VERSION
    gemspec.summary = "Simple enum-like field support for ActiveRecord (including validations and i18n)"
    gemspec.email = "lukas.westermann@gmail.com"
    gemspec.homepage = "http://github.com/lwe/simple_enum"
    gemspec.authors = ["Lukas Westermann"] # ask & add "Dmitry Polushkin"
    
    gemspec.files.reject! { |file| file =~ /\.gemspec$/ } # kinda redundant
  end
  Jeweler::GemcutterTasks.new  
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

namespace :metrics do
  desc 'Report code statistics for library and tests to shell.'
  task :stats do |t|
    require 'code_statistics'
    dirs = {
      'Libraries' => 'lib',
      'Unit tests' => 'test'
    }.map { |name,dir| [name, File.join(File.dirname(__FILE__), dir)] }
    CodeStatistics.new(*dirs).to_s
  end
  
  desc 'Report code coverage to HTML (doc/coverage) and shell (requires rcov).'
  task :coverage do |t|
    rm_f "doc/coverage"
    mkdir_p "doc/coverage"
    rcov = %(rcov -Ilib:test --exclude '\/gems\/' -o doc/coverage -T test/*_test.rb )
    system rcov
  end
end

desc 'Start IRB console with loaded test/test_helper.rb and sqlite db.'
task :console do |t|
  chdir File.dirname(__FILE__)
  exec 'irb -Ilib/ -r test/test_helper'
end

desc 'Clean up generated files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "pkg"  
end
