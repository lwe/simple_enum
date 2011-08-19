require 'test_helper'

class FindersTest < MiniTest::Unit::TestCase
  def setup
    reload_db
  end

  def test_find_all_female_genders
    girls = Dummy.where(:gender_cd => Dummy.genders[:female]).sort { |a,b| a.name <=> b.name }
    
    assert_equal 2, girls.length
    
    assert_equal 'Anna', girls.first.name
    assert_equal :female, girls.first.gender
    assert_equal true, girls.first.female?
  end
  
  def test_find_all_gamma_words
    gammas = Dummy.where(:word_cd => Dummy.words(:gamma)).all
    
    assert_equal 1, gammas.length
    assert_equal 'Chris', gammas.first.name
    assert_equal true, gammas.first.male?
    assert_equal 'gamma', gammas.first.word_cd
    assert_equal :gamma, gammas.first.word
  end
  
  def test_find_all_with_attribute_didum_equal_to_foo
    skip('Not available in Mongoid') if mongoid?
    
    foos = Dummy.where('other = ?', Dummy.didums(:foo)).all   
    
    assert_equal 1, foos.length
    assert_equal false, foos.first.foobar?
  end
  
  def test_find_using_insecure_inline_string_conditions
    skip('Not available in Mongoid') if mongoid?
    
    men = Dummy.where("gender_cd = #{Dummy.genders(:male)}").all
    
    assert_equal 1, men.length
    assert_equal true, men.first.male?
  end  
end