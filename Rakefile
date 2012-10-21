require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

desc 'Default: run all unit tests for both ActiveRecord & Mongoid.'
task :default => :test

namespace :test do
  Rake::TestTask.new(:units) do |t|
    t.libs << "test"
    t.test_files = Dir['test/*_test.rb']
    t.verbose = true
  end

  desc 'Run all unit tests for ActiveRecord'
  task :activerecord do |t|
    ENV['SIMPLE_ENUM_TEST_ORM'] = 'active_record'
    Rake::Task['test:units'].execute
  end

  desc 'Run all unit tests for Mongoid'
  task :mongoid do |t|
    ENV['SIMPLE_ENUM_TEST_ORM'] = 'mongoid'
    Rake::Task['test:units'].execute
  end
end

task :test => [:'test:activerecord', :'test:mongoid']

# Mongodb
directory "tmp/mongodb.data"
desc 'Run mongodb in tmp/'
task :mongodb => [:'tmp/mongodb.data'] do |t|
  system "mongod", "--dbpath", "tmp/mongodb.data"
end
