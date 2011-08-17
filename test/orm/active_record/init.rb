require 'active_record'
require 'active_record/version'
require File.join(File.dirname(__FILE__), '..', 'common')

def orm_version
  ActiveRecord::VERSION::STRING
end

def setup_db
  # create database connection (in memory db!)
  ActiveRecord::Base.establish_connection({
    :adapter => RUBY_PLATFORM =~ /java/ ? 'jdbcsqlite3' : 'sqlite3',
    :database => ':memory:'})    
end


# Reload database
def reload_db(options = {})
 
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
  
  fill_db(options)
end