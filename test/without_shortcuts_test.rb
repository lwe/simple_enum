require 'test_helper'

class WithoutShortcutsTest < MiniTest::Unit::TestCase  
  def setup
    reload_db
    
    named_dummy('SlimDummy') do
      as_enum :gender, [:male, :female], :slim => true
    end
  end

  def test_that_no_shortcut_methods_are_generated_if_slime_is_true
    jane = SlimDummy.new
    jane.gender = :female
    
    # ensure that other methods still work as expected
    assert_equal 1, jane.gender_cd
    assert_equal :female, jane.gender
    
    # then check for availability  of shortcut methods
    assert !jane.respond_to?(:male!), "should not respond_to <male!>"
    assert !jane.respond_to?(:female?), "should not respond_to <female?>"
  end
  
  def test_that_saving_and_loading_from_datasource_works_even_if_slim_is_true
    anna = SlimDummy.where(:name => 'Anna').first
    
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