require 'test_helper'

class SimpleEnumTest < ActiveSupport::TestCase  
  def setup
    reload_db
  end
  
  test "get the correct integer values when setting to symbol" do
    d = Dummy.new
    d.gender = :male
    assert_equal(0, d.gender_cd)
  end
  
  test "get the correct symbol when setting the integer value" do
    d = Dummy.new
    d.gender_cd = 1
    assert_equal(:female, d.gender)
  end
  
  test "verify that <symbol>? returns correct result" do
    d = Dummy.new
    d.gender = :male
    assert_equal(true, d.male?)
    assert_equal(false, d.female?)
  end
  
  test "get symbol when rows are fetched from db" do
    # Anna
    assert_equal(:female, Dummy.find(1).gender)
    assert_equal(:alpha, Dummy.find(1).word)
    assert_equal(:foo, Dummy.find(1).didum)
    
    # Bella
    assert_equal(true, Dummy.find(2).female?)
    assert_equal(true, Dummy.find(2).beta?)
    assert_equal(:bar, Dummy.find(2).didum)

    # Chris
    assert_equal(false, Dummy.find(3).female?)
    assert_equal(:gamma, Dummy.find(3).word)
    assert_equal(:foobar, Dummy.find(3).didum)    
  end
  
  test "create and save new record then test symbols" do
    d = Dummy.create({ :name => 'Dummy', :gender_cd => 0 }) # :gender => male
    assert_equal(true, d.male?)
    
    # change :gender_cd to 1
    d.female!
    d.save!    
    assert_equal(true, Dummy.find(d.id).female?)
  end
  
  test "add validation and test validations" do
    Dummy.class_eval { validates_as_enum :gender }
    
    d = Dummy.new :gender_cd => 5 # invalid number :)
    assert_equal(false, d.save)
    d.gender_cd = 1
    assert_equal(true, d.save)
    assert_equal(:female, d.gender)
  end
  
  test "raises ArgumentError if invalid symbol is passed" do
    assert_raise ArgumentError do
      Dummy.new :gender => :foo
    end
  end
  
  test "raises NO ArgumentError if :whiny => false is defined" do
    not_whiny = Class.new(Dummy) do
      as_enum :gender, [:male, :female], :whiny => false
    end
    
    d = not_whiny.new :gender => :foo
    assert_nil(d.gender)
    d.gender = ''
    assert_nil(d.gender)
  end
  
  test "ensure that setting to 'nil' works if :whiny => true and :whiny => false" do
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
