require 'rubygems'
require 'bundler/setup'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

desc 'Default: run all tests for both ActiveRecord & Mongoid.'
task :default => :spec

namespace :spec do
  desc 'Run all unit tests for ActiveRecord'
  RSpec::Core::RakeTask.new(:activerecord) do |t|
    t.rspec_opts = %w{--color --tag ~mongoid}
  end

  desc 'Run all unit tests for Mongoid'
  RSpec::Core::RakeTask.new(:mongoid) do |t|
    t.rspec_opts = %w{--color --tag ~activerecord}
  end
end

task :spec => [:'spec:activerecord', :'spec:mongoid']

# Start mongodb, useful for local development
directory "tmp/mongodb.data"
desc 'Run mongodb in tmp/'
task :mongodb => [:'tmp/mongodb.data'] do |t|
  system "mongod", "--dbpath", "tmp/mongodb.data"
end
