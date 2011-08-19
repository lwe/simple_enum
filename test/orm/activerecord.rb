require 'active_record/version'

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

# Models
def anonymous_dummy(&block)
  Class.new(ActiveRecord::Base) do
    set_table_name 'dummies'
    instance_eval &block 
  end
end

def named_dummy(class_name, &block)
  begin
    return class_name.constantize
  rescue NameError  
    klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))
    klass.module_eval do
      set_table_name 'dummies'
      instance_eval &block
    end
  
    klass
  end

end

class Dummy < ActiveRecord::Base
  as_enum :gender, [:male, :female]
  as_enum :word, { :alpha => 'alpha', :beta => 'beta', :gamma => 'gamma'}
  as_enum :didum, [ :foo, :bar, :foobar ], :column => 'other'  
end

class Gender < ActiveRecord::Base
end

# Used to test STI stuff
class SpecificDummy < Dummy
  set_table_name 'dummies'
end

