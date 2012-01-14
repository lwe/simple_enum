require 'test_helper'

class PrefixesTest < MiniTest::Unit::TestCase
  def setup
    reload_db
  end

  def test_that_gender_is_prefixed_in_getters_and_setters
    with_prefix = anonymous_dummy do
      as_enum :gender, [:male, :female], :prefix => true
    end
    
    d = with_prefix.new :gender => :male
    assert_respond_to d, :gender_male?
    assert_respond_to d, :gender_male!
    assert_respond_to d, :gender_female?
    assert_respond_to d, :gender_female!
    
    # just ensure that it DOES NOT RESPOND TO good old male!
    assert !d.respond_to?(:male!)
  end
  
  def test_that_custom_prefix_is_applied_to_getters_and_setters
    with_string_prefix = anonymous_dummy do
      as_enum :gender, [:male, :female], :prefix => 'didum'
    end
    
    d = with_string_prefix.new :gender => :female
    assert_respond_to d, :didum_female?
    assert_respond_to d, :didum_female!    
    
    # just check wheter the results are still correct :)
    assert d.didum_female?
    assert !d.didum_male?
  end
end