require 'test_helper'

class FindersTest < ActiveSupport::TestCase  
  def setup
    reload_db
  end

  test "find all where :gender = :female" do
    girls = Dummy.find :all, :conditions => { :gender_cd => Dummy.genders[:female] }, :order => 'name ASC'
    
    assert_equal 2, girls.length
    
    assert_equal 'Anna', girls.first.name
    assert_equal :female, girls.first.gender
    assert_equal true, girls.first.female?
  end
  
  test "find all where :word is 'gamma'" do
    gammas = Dummy.find :all, :conditions => { :word_cd => Dummy.words(:gamma) }
    
    assert_equal 1, gammas.length
    assert_equal 'Chris', gammas.first.name
    assert_equal true, gammas.first.male?
    assert_equal 'gamma', gammas.first.word_cd
    assert_equal :gamma, gammas.first.word
  end
  
  test "find with string conditions for all :didum = :foo" do
    foos = Dummy.find :all, :conditions => ['other = ?', Dummy.didums(:foo)]
    
    assert_equal 1, foos.length
    assert_equal false, foos.first.foobar?
  end
  
  test "find using insecure inline string conditions" do
    men = Dummy.find :all, :conditions => "gender_cd = #{Dummy.genders(:male)}"
    
    assert_equal 1, men.length
    assert_equal true, men.first.male?
  end  
end