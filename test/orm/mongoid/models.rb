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
  self.collection_name = 'dummies'  
  as_enum :gender, [:male, :female]
  as_enum :word, { :alpha => 'alpha', :beta => 'beta', :gamma => 'gamma'}
  as_enum :didum, [ :foo, :bar, :foobar ], :column => 'other'  
  
  def method_missing(m, *args, &block)
    p "METHOD MISSING #{m.inspect}"

  end
end

class Gender
  include Mongoid::Document
  
  field :name, :type => String
end

# Used to test STI stuff
class SpecificDummy < Dummy
  include Mongoid::Document 
  self.collection_name = 'dummies'
end

