require 'active_record/version'

def orm_version
  ActiveRecord::VERSION::STRING
end

def ar32?
  ActiveRecord::VERSION::MAJOR >= 3 && ActiveRecord::VERSION::MINOR >= 2
end

def setup_db
  # create database connection (in memory db!)
  ActiveRecord::Base.establish_connection({
    :adapter => RUBY_PLATFORM =~ /java/ ? 'jdbcsqlite3' : 'sqlite3',
    :database => ':memory:'})
    
  # Fix visitor, for JRuby
  if RUBY_PLATFORM =~ /java/ && ar32?
    ActiveRecord::ConnectionAdapters::SQLiteAdapter.send(:define_method, :visitor) do
      @visitor ||= Arel::Visitors::SQLite.new(self)
    end
  end
end

# Reload database
def reload_db(options = {})
  ActiveRecord::Base.connection.create_table :dummies, :force => true do |t|
    t.column :name, :string
    t.column :gender_cd, :integer
    t.column :word_cd, :string, :limit => 5
    t.column :role_cd, :string
    t.column :other, :integer
    t.column :numeric_cd, :string
    t.column :nilish_cd, :string
  end

  # Create ref-data table and fill with records
  ActiveRecord::Base.connection.create_table :genders, :force => true do |t|
    t.column :name, :string
  end
  
  # Validations
  ActiveRecord::Base.connection.create_table :computers, :force => true do |t|
    t.column :name, :string
    t.column :operating_system_cd, :integer
    t.column :manufacturer_cd, :integer
  end  
  
  fill_db(options)
end

# Models
def anonymous_dummy(&block)
  Class.new(ActiveRecord::Base) do
    ar32? ? self.table_name = 'dummies' : set_table_name('dummies')
    instance_eval &block 
  end
end

def extend_computer(current_i18n_name = "Computer", &block)
  Class.new(Computer) do
    ar32? ? self.table_name = 'computers' : set_table_name('computers')
    instance_eval &block
    instance_eval <<-RUBY
      def self.model_name; MockName.mock!(#{current_i18n_name.inspect}) end
    RUBY
  end
end

def extend_dummy(current_i18n_name = "Dummy", &block)
  Class.new(Dummy) do
    ar32? ? self.table_name = 'dummies' : set_table_name('dummies')
    instance_eval &block
    instance_eval <<-RUBY
      def self.model_name; MockName.mock!(#{current_i18n_name.inspect}) end
    RUBY
  end
end

def named_dummy(class_name, &block)
  begin
    return class_name.constantize
  rescue NameError
    klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))
    klass.module_eval do
      ar32? ? self.table_name = 'dummies' : set_table_name('dummies')
      instance_eval &block
    end
    klass
  end
end

class Dummy < ActiveRecord::Base
  as_enum :gender, [:male, :female]
  as_enum :word, { :alpha => 'alpha', :beta => 'beta', :gamma => 'gamma'}
  as_enum :didum, [ :foo, :bar, :foobar ], :column => 'other'
  as_enum :role, [:admin, :member, :anon], :strings => true
  as_enum :numeric, [:"100", :"3.14"], :strings => true
  as_enum :nilish, [:nil], :strings => true
end

class Gender < ActiveRecord::Base
end

class Computer < ActiveRecord::Base
  as_enum :manufacturer, [:dell, :compaq, :apple]
  as_enum :operating_system, [:windows, :osx, :linux, :bsd]
end

# Used to test STI stuff
class SpecificDummy < Dummy
  ar32? ? self.table_name = 'dummies' : set_table_name('dummies')
end

