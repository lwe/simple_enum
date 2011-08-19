require 'test_helper'

class ArrayConversionsTest < MiniTest::Unit::TestCase
  def setup
    reload_db :genders => true
  end
  
  def test_conversion_to_enumartions
    with_enum = named_dummy('DummyArrayTest1') do
       as_enum :gender, Gender.all.map { |g| [g.name.to_sym, g.id] }       
    end   
    
    assert_equal @male.id, with_enum.male
    assert_equal @female.id, with_enum.female
    assert_equal @female.id, with_enum.genders(:female)
    
    jane = with_enum.new :gender => :female
    assert_equal :female, jane.gender
    assert_equal @female.id, jane.gender_cd    
  end
end