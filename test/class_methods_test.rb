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
  end
  
  test "that inst.values_for_... is deprecated (by trapping Kernel\#warn)" do
    # ensure that warn() is trapped
    trapped_warn_dummy = Class.new(Dummy) do
      @@LAST_WARNING = nil
      def warn(msg); @@LAST_WARNING = msg; end;
      def self.last_warning; @@LAST_WARNING; end      
    end
    
    g = trapped_warn_dummy.new
    g.values_for_gender
    
    assert_match /\ADEPRECATION WARNING.*values_for_gender.*genders/, trapped_warn_dummy.last_warning
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
    with_slim = Class.new(ActiveRecord::Base) do
      set_table_name 'dummy'
      as_enum :gender, [:male, :female], :slim => true
    end

    assert !with_slim.respond_to?(:male)
    assert !with_slim.respond_to?(:female)    
    assert_respond_to with_slim, :genders
  end
  
  test "that Klass.shortcut respect :prefix => true and are prefixed by \#{enum_cd}" do
    with_prefix = Class.new(ActiveRecord::Base) do
      set_table_name 'dummy'
      as_enum :gender, [:male, :female], :prefix => true
    end
    
    assert !with_prefix.respond_to?(:male)
    assert !with_prefix.respond_to?(:female)    
    assert_respond_to with_prefix, :gender_male
    assert_respond_to with_prefix, :gender_female
    assert_equal 0, with_prefix.gender_male
    assert_respond_to with_prefix, :genders
  end
  
  test "to ensure that Klass.shortcut also work with custom prefixes" do
    with_custom_prefix = Class.new(ActiveRecord::Base) do
      set_table_name 'dummy'
      as_enum :gender, [:male, :female], :prefix => :g
    end
    
    assert !with_custom_prefix.respond_to?(:male)
    assert !with_custom_prefix.respond_to?(:female)    
    assert !with_custom_prefix.respond_to?(:gender_female)        
    assert_respond_to with_custom_prefix, :g_male
    assert_respond_to with_custom_prefix, :g_female
    assert_equal 1, with_custom_prefix.g_female    
    assert_respond_to with_custom_prefix, :genders    
  end
end