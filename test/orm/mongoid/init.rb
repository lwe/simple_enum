require 'mongoid'
require 'mongoid/version'
require File.join(File.dirname(__FILE__), '..', 'common')

def orm_version
  Mongoid::VERSION
end

def setup_db
  # create database connection
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new('127.0.0.1', 27017).db("simple-enum-test-suite")
    config.use_utc = true
    config.include_root_in_json = true
  end  
end


# Reload database
def reload_db(options = {})
 
  # clear collections except system
  Mongoid.master.collections.select do |collection|
    collection.name !~ /system/
  end.each(&:drop)
  
  fill_db(options)
end