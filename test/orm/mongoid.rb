require 'mongoid/version'

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

# models
def anonymous_dummy(&block)
  Class.new do
    include Mongoid::Document 
    self.collection_name = 'dummies'
    instance_eval &block 
  end
end

def named_dummy(class_name, &block)
  begin
    return class_name.constantize
  rescue NameError  
    klass = Object.const_set(class_name, Class.new)
    klass.module_eval do
      include Mongoid::Document 
      self.collection_name = 'dummies'      
      instance_eval &block
    end
  
    klass
  end

end

class Dummy
  include Mongoid::Document 

  as_enum :gender, [:male, :female]
  as_enum :word, { :alpha => 'alpha', :beta => 'beta', :gamma => 'gamma'}
  as_enum :didum, [ :foo, :bar, :foobar ], :column => 'other'  
  
  before_save :check_typed
  
  def check_typed
    attributes['_type'] = nil unless (self.hereditary? || self.polymorphic?)
  end
  
end

class Gender
  include Mongoid::Document
  
  field :name, :type => String
end

# Used to test STI stuff
class SpecificDummy < Dummy;end
