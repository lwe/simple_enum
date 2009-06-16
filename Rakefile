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

desc 'Start IRB console with loaded test/test_helper.rb.'
task :console do |t|
  chdir File.dirname(__FILE__)
  exec 'irb -Ilib/ -r test/test_helper'
end

desc 'Generate documentation for the simple_enum plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'SimpleEnum'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.include('LICENCE');
end

desc 'Clean up generated files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
end
