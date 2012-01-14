require 'test_helper'

class ObjectBackedTest < MiniTest::Unit::TestCase
  def setup
    reload_db :genders => true    
  end

  def test_how_working_with_object_backed_columns_work
    # simple object -> not db backed instance
    simple_obj = Class.new do
      attr_accessor :name
      def initialize(name)
        @name = name
      end  
    end
        
    # create new class by using simple_obj
    with_object = anonymous_dummy do
      as_enum :gender, { simple_obj.new('Male') => 0, simple_obj.new('Female') => 1 }      
    end
        
    d = with_object.where(:name => 'Anna').first
    
    assert_same simple_obj, d.gender.class
    assert_equal 'Female', d.gender.name
    assert_same true, d.female?
    assert_same false, d.male?
    assert_same 0, with_object.male    
  end
  
  def test_db_backed_objects
    # using method described in 'Advanced Rails Recipes - Recipe 61: Look Up Constant Data Efficiently'
    # "cache" as defined in ARR#61
    genders = Gender.all
    # works without mapping... .map { |g| [g, g.id] }
    
    # use cached array of values
    with_db_obj = anonymous_dummy do
      as_enum :gender, genders
    end
    
    d = with_db_obj.where(:name => 'Bella').first
    
    assert_respond_to with_db_obj, :female
    assert_respond_to with_db_obj, :male
    assert_equal 0, with_db_obj.male
  end
  
  def test_that_accesing_keys_and_values_of_each_enumeration_value_works_as_expected

    with_db_obj = anonymous_dummy do
      as_enum :gender, Gender.all.to_a
    end
    
    assert_same 0, with_db_obj.male
    assert_equal @male.id, with_db_obj.male(true).id
    
    assert_same :male, Dummy.male(true)
    assert_same 0, Dummy.male
  end
end