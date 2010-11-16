require 'test_helper'

class ArrayConversionsTest < ActiveSupport::TestCase  
  def setup
    reload_db :genders => true
  end
  
  test "that conversion of Gender.find(:all).map {...} to enumeration values as symbols works the same as [:male,:female]" do
    class DummyArrayTest1 < ActiveRecord::Base
      set_table_name 'dummies'
      as_enum :gender, Gender.find(:all).map { |g| [g.name.to_sym, g.id] }
    end
    with_enum = DummyArrayTest1
    
    assert_equal 0, with_enum.male
    assert_equal 1, with_enum.female
    assert_equal 1, with_enum.genders(:female)
    
    jane = with_enum.new :gender => :female
    assert_equal :female, jane.gender
    assert_equal 1, jane.gender_cd    
  end
end