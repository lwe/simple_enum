# Setup environment for both tests and IRB interactive console
#

require 'rubygems'

gem 'sqlite3-ruby'

require 'active_support'
require 'active_record'

# setup fake rails env
ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = 'test'

# create database connection (in memory db!)
ActiveRecord::Base.establish_connection({ :adapter => 'sqlite3', :database => ':memory:'})

# load simple_enum
require File.join(ROOT, 'lib', 'simple_enum')

# load dummy class
require File.join(ROOT, 'test', 'dummy')

# Reload database
def reload_db(fill = true)
  ActiveRecord::Base.connection.create_table :dummies, :force => true do |t|
    t.column :name, :string
    t.column :gender_cd, :integer
    t.column :word_cd, :string, :limit => 5
    t.column :other, :integer
  end
  
  if fill
    # fill db with some rows
    Dummy.create({ :name => 'Anna',  :gender_cd => 1, :word_cd => 'alpha', :other => 0})
    Dummy.create({ :name => 'Bella', :gender_cd => 1, :word_cd => 'beta', :other => 1})
    Dummy.create({ :name => 'Chris', :gender_cd => 0, :word_cd => 'gamma', :other => 2})
  end
end

# do some magic to include/exclude stuff for IRB session vs. Unit Tests
if Object.const_defined?('IRB')
  reload_db # init DB for IRB
else
  require 'test/unit'
  require 'active_support/test_case'
end