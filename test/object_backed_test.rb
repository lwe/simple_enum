require 'test_helper'

class Gender < ActiveRecord::Base
  # def to_param; name.underscore; end
end

class ObjectBackedTest < ActiveSupport::TestCase  
  def setup
    reload_db
    
    ActiveRecord::Base.connection.create_table :genders, :force => true do |t|
      t.column :name, :string
    end
    
    male = Gender.new({ :name => 'male' })
    male.id = 0;
    male.save!
    
    female = Gender.new({ :name => 'female' })
    female.id = 1;
    female.save!    
  end

  test "how working with object backed columns work..." do
    # simple object -> not db backed instance
    simple_obj = Class.new do
      attr_accessor :name
      def initialize(name)
        @name = name
      end  
      def to_param; name; end      
    end
    
    # create new class by using simple_obj
    with_object = Class.new(ActiveRecord::Base) do
      set_table_name 'dummies'      
      as_enum :gender, { simple_obj.new('male') => 0, simple_obj.new('female') => 1 }      
    end
    
    d = with_object.find_by_name('Anna')
    
    assert_same simple_obj, d.gender.class
    assert_equal 'female', d.gender.name
    assert_same true, d.female?
    assert_same false, d.male?
    assert_same 0, with_object.male    
  end
  
  test "db backed objects, using method described in 'Advanced Rails Recipes: Recipe 61: Look Up Constant Data Efficiently'" do
    # "cache" as defined in ARR#61
    genders = Gender.find(:all).map do |g|
      [g, g.id]
    end
    
    # use cached array of values
    with_db_obj = Class.new(ActiveRecord::Base) do
      set_table_name 'dummies'
      as_enum :gender, genders
    end
    
    d = with_db_obj.find_by_name('Bella');
    
    assert_respond_to with_db_obj.female
    assert_respond_to with_db_obj.male
    assert_equal 0, with_db_obj.male
  end
end