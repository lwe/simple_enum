require 'rubygems'
require 'bundler'
require 'rake/testtask'

include Rake::DSL

Bundler::GemHelper.install_tasks

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the simple_enum plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.verbose = true
end
