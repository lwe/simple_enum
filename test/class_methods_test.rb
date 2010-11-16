require 'test_helper'

class ClassMethodsTest < ActiveSupport::TestCase  
  def setup
    reload_db
  end

  test "that Klass.genders[:sym] == Klass.genders(:sym)" do
    assert_equal 0, Dummy.genders(:male)
    assert_equal Dummy.genders(:male), Dummy.genders[:male]
    assert_nil Dummy.genders(:inexistent)
    assert_nil Dummy.genders[:inexistent]
    assert_not_nil Dummy.genders[:female]
  end
  
  test "inheritance of `genders` to subclasses (#issue/3)" do
    assert_equal({ :female => 1, :male => 0}, SpecificDummy.genders)
  end

  test "genders reader created" do
    assert_equal [0, 1], Dummy.genders.values.sort
    assert_equal %w{female male}, Dummy.genders.keys.map(&:to_s).sort
  end

  test "that Klass.genders(:sym_a, :sym_b) returns an array of values, useful for IN clauses" do
    assert_equal [0, 1], Dummy.genders(:male, :female)
    assert_equal [1, 0], Dummy.genders(:female, :male)
  end
    
  test "generation of value shortcuts on class" do
    g = Dummy.new
    
    assert_equal 0, Dummy.male
    assert_equal 1, Dummy.female
    assert_equal 'alpha', Dummy.alpha
    assert_respond_to Dummy, :male
    assert_respond_to Dummy, :female
    assert_respond_to Dummy, :beta
    assert_respond_to Dummy, :foobar            
  end
  
  test "that no Klass.shortcut are created if :slim => true" do
    class Dummy1 < ActiveRecord::Base
      set_table_name 'dummies'
      as_enum :gender, [:male, :female], :slim => true
    end
    with_slim = Dummy1

    assert !with_slim.respond_to?(:male)
    assert !with_slim.respond_to?(:female)    
    assert_respond_to with_slim, :genders
  end
  
  test "that no Klass.shortcut's are created if :slim => :class, though instance shortcuts are" do
    class Dummy2 < ActiveRecord::Base
      set_table_name 'dummies'
      as_enum :gender, [:male, :female], :slim => :class
    end
    with_slim_class = Dummy2
    
    jane = with_slim_class.new
    
    assert_respond_to jane, :male!
    assert_respond_to jane, :female!
    assert !with_slim_class.respond_to?(:male)
    assert !with_slim_class.respond_to?(:female)    
    assert_respond_to with_slim_class, :genders
    assert_same 0, with_slim_class.genders.male
    assert_same 1, with_slim_class.genders[:female]
  end
  
  test "that Klass.shortcut respect :prefix => true and are prefixed by \#{enum_cd}" do
    class Dummy3 < ActiveRecord::Base
      set_table_name 'dummies'
      as_enum :gender, [:male, :female], :prefix => true
    end
    with_prefix = Dummy3
    
    assert !with_prefix.respond_to?(:male)
    assert !with_prefix.respond_to?(:female)    
    assert_respond_to with_prefix, :gender_male
    assert_respond_to with_prefix, :gender_female
    assert_equal 0, with_prefix.gender_male
    assert_respond_to with_prefix, :genders
  end
  
  test "to ensure that Klass.shortcut also work with custom prefixes" do
    class Dummy4 < ActiveRecord::Base
      set_table_name 'dummies'
      as_enum :gender, [:male, :female], :prefix => :g
    end
    with_custom_prefix = Dummy4
    
    assert !with_custom_prefix.respond_to?(:male)
    assert !with_custom_prefix.respond_to?(:female)    
    assert !with_custom_prefix.respond_to?(:gender_female)        
    assert_respond_to with_custom_prefix, :g_male
    assert_respond_to with_custom_prefix, :g_female
    assert_equal 1, with_custom_prefix.g_female    
    assert_respond_to with_custom_prefix, :genders    
  end
    
  test "that the human_enum_name method returns translated/humanized values" do
    assert_equal :male.to_s.humanize, Dummy.human_enum_name(:genders, :male)
    assert_equal "Girl", Dummy.human_enum_name(:genders, :female)
    assert_equal "Foo", Dummy.human_enum_name(:didums, :foo)
    assert_equal "Foos", Dummy.human_enum_name(:didums, :foo, :count => 5)
  end

  test "enum_for_select class method" do
    for_select = Dummy.genders_for_select
    assert_equal ["Girl", :female], for_select.first
    assert_equal ["Male", :male], for_select.last
  end
end