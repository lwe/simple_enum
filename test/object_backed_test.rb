require 'test_helper'

class ObjectBackedTest < ActiveSupport::TestCase  
  def setup
    reload_db :genders => true    
  end

  test "how working with object backed columns work..." do
    # simple object -> not db backed instance
    simple_obj = Class.new do
      attr_accessor :name
      def initialize(name)
        @name = name
      end  
    end
    
    # create new class by using simple_obj
    with_object = Class.new(ActiveRecord::Base) do
      set_table_name 'dummies'      
      as_enum :gender, { simple_obj.new('Male') => 0, simple_obj.new('Female') => 1 }      
    end
    
    d = with_object.find_by_name('Anna')
    
    assert_same simple_obj, d.gender.class
    assert_equal 'Female', d.gender.name
    assert_same true, d.female?
    assert_same false, d.male?
    assert_same 0, with_object.male    
  end
  
  test "db backed objects, using method described in 'Advanced Rails Recipes - Recipe 61: Look Up Constant Data Efficiently'" do
    # "cache" as defined in ARR#61
    genders = Gender.find(:all)
    # works without mapping... .map { |g| [g, g.id] }
    
    # use cached array of values
    with_db_obj = Class.new(ActiveRecord::Base) do
      set_table_name 'dummies'
      as_enum :gender, genders
    end
    
    d = with_db_obj.find_by_name('Bella');
    
    assert_respond_to with_db_obj, :female
    assert_respond_to with_db_obj, :male
    assert_equal 0, with_db_obj.male
  end
  
  test "that accessing keys and values of each enumeration value works as expected" do
    genders = Gender.find(:all, :order => :id)
    
    male = genders.first
    female = genders.last
    
    with_db_obj = Class.new(ActiveRecord::Base) do
      set_table_name 'dummies'
      as_enum :gender, genders
    end
    
    assert_same male.id, with_db_obj.male
    assert_same male, with_db_obj.male(true)
    
    assert_same :male, Dummy.male(true)
    assert_same 0, Dummy.male
  end
end