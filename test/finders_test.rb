require 'test_helper'

# Trap Kernel#warn to check that deprecated warning is added :)
module Kernel
  @@LAST_WARNING = nil
  def warn(msg)
    @@LAST_WARNING = msg
  end
  
  def self.last_warning; @@LAST_WARNING; end
end

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
  
  test "that Klass.genders[:sym] == Klass.genders(:sym)" do
    assert_equal 0, Dummy.genders(:male)
    assert_equal Dummy.genders(:male), Dummy.genders[:male]
    assert_nil Dummy.genders(:inexistent)
    assert_nil Dummy.genders[:inexistent]
  end
  
  test "that inst.values_for_... is deprecated (by trapping Kernel\#warn)" do
    g = Dummy.new
    g.values_for_gender
    
    assert_match /\ADEPRECATION WARNING.*values_for_gender.*genders/, Kernel.last_warning
  end
end