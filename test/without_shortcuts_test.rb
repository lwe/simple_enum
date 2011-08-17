require 'test_helper'

class WithoutShortcutsTest < ActiveSupport::TestCase  
  def setup
    reload_db
    
    named_dummy('SlimDummy') do
      as_enum :gender, [:male, :female], :slim => true
    end
  end

  test "that no shortcut methods are generated if :slim => true" do
    jane = SlimDummy.new
    jane.gender = :female
    
    # ensure that other methods still work as expected
    assert_equal 1, jane.gender_cd
    assert_equal :female, jane.gender
    
    # then check for availability  of shortcut methods
    assert !jane.respond_to?(:male!), "should not respond_to <male!>"
    assert !jane.respond_to?(:female?), "should not respond_to <female?>"
  end
  
  test "that saving and loading from a DB still works, even if :slim => true" do
    anna = SlimDummy.find_by_name 'Anna'
    
    assert_equal 1, anna.gender_cd
    assert_equal :female, anna.gender
    
    # change anna, save + reload
    anna.gender = :male
    anna.save!
    anna.reload
    
    assert_equal 0, anna.gender_cd
    assert_equal :male, anna.gender
  end
end