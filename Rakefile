require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

desc 'Default: run all unit tests for both ActiveRecord & Mongoid.'
task :default => :spec

desc 'Run rspec test suite'
task :spec do
  sh 'bundle exec rspec spec/'
end

# Mongodb
directory "tmp/mongodb.data"
desc 'Run mongodb in tmp/'
task :mongodb => [:'tmp/mongodb.data'] do |t|
  system "mongod", "--dbpath", "tmp/mongodb.data"
end
