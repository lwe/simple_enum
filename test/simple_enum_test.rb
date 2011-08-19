require 'test_helper'

class SimpleEnumTest < MiniTest::Unit::TestCase
  def setup
    reload_db
  end
  
  def test_getting_the_correct_integer_values_when_setting_to_symbol
    d = Dummy.new
    d.gender = :male
    assert_equal(0, d.gender_cd)
  end
  
  def test_getting_the_correct_symbold_when_setting_the_integer_value
    d = Dummy.new
    d.gender_cd = 1
    assert_equal(:female, d.gender)
  end
  
  def test_that_checker_returns_correct_result
    d = Dummy.new
    d.gender = :male
    assert_equal(true, d.male?)
    assert_equal(false, d.female?)
  end
  
  def test_getting_symbol_when_data_is_fetched_from_datasource
    # Anna
    
    dummies = Dummy.all
    
    assert_equal(:female, dummies[0].gender)
    assert_equal(:alpha, dummies[0].word)
    assert_equal(:foo, dummies[0].didum)
    
    # Bella
    assert_equal(true, dummies[1].female?)
    assert_equal(true, dummies[1].beta?)
    assert_equal(:bar, dummies[1].didum)

    # Chris
    assert_equal(false, dummies[2].female?)
    assert_equal(:gamma, dummies[2].word)
    assert_equal(:foobar, dummies[2].didum)    
  end
  
  def test_creating_and_saving_a_new_datasource_object_then_test_symbols
    d = Dummy.create({ :name => 'Dummy', :gender_cd => 0 }) # :gender => male
    assert_equal(true, d.male?)
    
    # change :gender_cd to 1
    d.female!
    d.save!    
    assert_equal(true, Dummy.find(d.id).female?)
  end
  
  def test_add_validation_and_test_validations
    Dummy.class_eval { validates_as_enum :gender }
    
    d = Dummy.new :gender_cd => 5 # invalid number :)
    assert_equal(false, d.save)
    d.gender_cd = 1
    assert_equal(true, d.save)
    assert_equal(:female, d.gender)
  end
  
  def test_that_argumenterror_is_raised_if_invalid_symbol_is_passed
    assert_raises ArgumentError do
      Dummy.new :gender => :foo
    end
  end
  
  def test_that_no_argumenterror_is_raised_if_whiny_is_false
    not_whiny = Class.new(Dummy) do
      as_enum :gender, [:male, :female], :whiny => false
    end
    
    d = not_whiny.new :gender => :foo
    assert_nil(d.gender)
    d.gender = ''
    assert_nil(d.gender)
  end
  
  def test_that_setting_to_nil_works_if_whiny_is_true_or_false
    d = Dummy.new :gender => :male    
    assert_equal(:male, d.gender)
    d.gender = nil
    assert_nil(d.gender)
    d.gender = ''
    assert_nil(d.gender)
    
    not_whiny_again = Class.new(Dummy) do
      as_enum :gender, [:male, :female], :whiny => false
    end
    
    d = not_whiny_again.new :gender => :male
    assert_equal(:male, d.gender)
    d.gender = nil
    assert_nil(d.gender)
    d.gender = ''
    assert_nil(d.gender)
  end
end
