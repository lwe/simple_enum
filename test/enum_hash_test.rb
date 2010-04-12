require 'test_helper'
require 'simple_enum/enum_hash'

class EnumHashTest < ActiveSupport::TestCase  
  
  test "create new EnumHash instance from array of symbols" do
    genders = SimpleEnum::EnumHash.new [:male, :female]
    
    assert_same 0, genders[:male]
    assert_same 1, genders[:female]
    assert_same 0, genders.male
    assert_same :female, genders.female(true)
  end

  test "create new EnumHash instance from Hash" do
    status = SimpleEnum::EnumHash.new :inactive => 0, :active => 1, :archived => 99
    
    assert_same 0, status.inactive
    assert_same 1, status[:active]
  end
  
  test "create new EnumHash instance from ActiveRecord results" do
    reload_db :genders => true
    genders = SimpleEnum::EnumHash.new Gender.find(:all)
    
    male = Gender.find(0)
    
    assert_same 0, genders[male]
    assert_same genders[male], genders[:male]
    assert_same 1, genders.female
    assert_equal male, genders.send(:male, true)
  end
  
  test "that EnumHash keys are ordered" do
    ordered = SimpleEnum::EnumHash.new [:alpha, :beta, :gamma, :delta, :epsilon, :zeta, :eta]
    expected_keys = [:alpha, :beta, :gamma, :delta, :epsilon, :zeta, :eta]
    assert_equal expected_keys, ordered.keys
  end
  
  test "that when simple array is merge into a EnumHash, array values are the keys and indicies are values" do
    a = [:a, :b, :c, :d]
    h = SimpleEnum::EnumHash.new(a)
    
    assert_same 0, h[:a]
    assert_same 1, h[:b]
    assert_same 2, h[:c]
    assert_same 3, h[:d]
    assert_equal [:a, :b, :c, :d], h.keys
  end
  
  test "that an already 'correct' looking array is converted to a hash" do
    a = [[:a, 5], [:b, 10]]
    h = SimpleEnum::EnumHash.new(a)
    
    assert_same 5, h[:a]
    assert_same 10, h[:b]
    assert_equal [:a, :b], h.keys
  end
  
  test "that an array of ActiveRecords are converted to <obj> => obj.id" do
    reload_db :genders => true # reload db
    a = Gender.find(:all, :order => :id)
    
    male = Gender.find(0)
    female = Gender.find(1)
    
    h = SimpleEnum::EnumHash.new(a)
    
    assert_same 0, h[male]
    assert_same 1, h[female]
  end  
end