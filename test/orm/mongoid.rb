require 'mongoid/version'
require 'simple_enum/mongoid'

def orm_version
  Mongoid::VERSION
end

def setup_db
  # create database connection
  Mongoid.configure do |config|
    config.master = Mongo::Connection.new('localhost').db("simple-enum-test-suite")
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
    include SimpleEnum::Mongoid
    self.collection_name = 'dummies'
    instance_eval &block
  end
end

def extend_computer(current_i18n_name = "Computer", &block)
  Class.new(Computer) do
    self.collection_name = 'computers'
    instance_eval &block
    instance_eval <<-RUBY
      def self.model_name; MockName.mock!(#{current_i18n_name.inspect}) end
    RUBY
  end
end

def extend_dummy(current_i18n_name = "Dummy", &block)
  Class.new(Dummy) do
    self.collection_name = 'dummies'
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
    klass = Object.const_set(class_name, Class.new)
    klass.module_eval do
      include Mongoid::Document
      include SimpleEnum::Mongoid

      self.collection_name = 'dummies'
      instance_eval &block
    end

    klass
  end

end

class Dummy
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :gender, [:male, :female]
  as_enum :word, { :alpha => 'alpha', :beta => 'beta', :gamma => 'gamma'}
  as_enum :didum, [ :foo, :bar, :foobar ], :column => 'other'
  as_enum :role, [:admin, :member, :anon], :strings => true
  as_enum :numeric, [:"100", :"3.14"], :strings => true
  as_enum :nilish, [:nil], :strings => true

  before_save :check_typed

  def check_typed
    attributes['_type'] = nil unless (self.hereditary? || self.polymorphic?)
  end

end

class Gender
  include Mongoid::Document
  include SimpleEnum::Mongoid

  field :name, :type => String
end

class Computer
  include Mongoid::Document
  include SimpleEnum::Mongoid

  field :name, :type => String

  as_enum :manufacturer, [:dell, :compaq, :apple]
  as_enum :operating_system, [:windows, :osx, :linux, :bsd]
end

# Used to test STI stuff
class SpecificDummy < Dummy; end
