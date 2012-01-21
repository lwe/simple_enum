require 'rubygems'
require 'bundler/setup'
require 'appraisal'
require 'rake/testtask'

include Rake::DSL

Bundler::GemHelper.install_tasks

desc 'Default: run unit tests.'
task :default => :test

desc 'Run unit tests, use ORM=...'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = Dir.glob('test/**/*_test.rb')
  t.verbose = true
end
