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
end