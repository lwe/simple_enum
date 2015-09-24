require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

desc 'Default: run all unit tests for both ActiveRecord & Mongoid.'
task :default => :'spec:all'

desc 'Run basic specs only (skips mongoid)'
task :spec => :'spec:basic'

namespace :spec do
  desc 'Run all specs'
  task :all do
    sh 'bundle', 'exec', 'rspec', 'spec/'
  end

  task :basic do
    sh 'bundle', 'exec', 'rspec', 'spec/', '-t', '~mongoid'
  end
end

# Mongodb
directory "tmp/mongodb.data"
desc 'Run mongodb in tmp/'
task :mongodb => [:'tmp/mongodb.data'] do |t|
  system "mongod", "--dbpath", "tmp/mongodb.data"
end
