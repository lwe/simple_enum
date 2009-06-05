require 'test_helper'

class PrefixesTest < ActiveSupport::TestCase  
  def setup
    reload_db
  end

  test "set :prefix => true and ensure that 'gender' is prefixed to <symbol>? and <symbol>! methods" do
    with_prefix = Class.new(ActiveRecord::Base) do
      set_table_name 'dummies'
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
  
  test "set :prefix => 'didum' and ensure that 'didum' is prefix to <symbol>? and <symbol>! methods" do
    with_string_prefix = Class.new(ActiveRecord::Base) do
      set_table_name 'dummies'
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