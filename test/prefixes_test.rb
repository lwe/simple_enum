require 'test_helper'

class SimpleEnumTest < ActiveSupport::TestCase  
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
end