# Setup environment for both tests and IRB interactive console
#

$KCODE = 'u' unless RUBY_VERSION =~ /^1\.9/ # to make parameterize work...

require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'active_support'
require 'active_record'

# setup fake rails env
ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = 'test'

# create database connection (in memory db!)
ActiveRecord::Base.establish_connection({
  :adapter => RUBY_PLATFORM =~ /java/ ? 'jdbcsqlite3' : 'sqlite3',
  :database => ':memory:'})

# load simple_enum
require File.join(ROOT, 'init')

# load dummy class
require File.join(ROOT, 'test', 'models')

# Reload database
def reload_db(options = {})
  options = { :fill => true, :genders => false }.merge(options)
  ActiveRecord::Base.connection.create_table :dummies, :force => true do |t|
    t.column :name, :string
    t.column :gender_cd, :integer
    t.column :word_cd, :string, :limit => 5
    t.column :other, :integer
  end
  
  # Create ref-data table and fill with records
  ActiveRecord::Base.connection.create_table :genders, :force => true do |t|
    t.column :name, :string
  end  
  
  if options[:fill]
    # fill db with some rows
    Dummy.create({ :name => 'Anna',  :gender_cd => 1, :word_cd => 'alpha', :other => 0})
    Dummy.create({ :name => 'Bella', :gender_cd => 1, :word_cd => 'beta', :other => 1})
    Dummy.create({ :name => 'Chris', :gender_cd => 0, :word_cd => 'gamma', :other => 2})
  end
  
  if options[:genders]    
    male = Gender.new({ :name => 'male' })
    male.id = 0;
    male.save!
    
    female = Gender.new({ :name => 'female' })
    female.id = 1;
    female.save!
  end
end

# do some magic to initialze DB for IRB session
if Object.const_defined?('IRB')
  reload_db :fill => true, :genders => true
else # and load test classes when in test cases...
  require 'test/unit'  
  require 'active_support/test_case'
end