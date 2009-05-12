require 'rubygems'
require 'test/unit'

gem 'sqlite3-ruby'

require 'active_support'
require 'active_support/test_case'
require 'active_record'

# setup fake rails env
ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = 'test'

# create database connection (in memory db!)
ActiveRecord::Base.establish_connection({ :adapter => 'sqlite3', :database => ':memory:'})

# load simple_enum
require File.join(ROOT, 'lib', 'simple_enum')