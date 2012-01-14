require 'test_helper'

class ClassMethodsTest < MiniTest::Unit::TestCase
  def setup
    reload_db
  end

  def test_that_klass_genders_array_accessor_equal_to_attr_accessor
    assert_equal 0, Dummy.genders(:male)
    assert_equal Dummy.genders(:male), Dummy.genders[:male]
    assert_nil Dummy.genders(:inexistent)
    assert_nil Dummy.genders[:inexistent]
    refute_nil Dummy.genders[:female]
  end

  def test_inheritance_of_genders_to_subclasses
    # issue#3
    assert_equal({ :female => 1, :male => 0}, SpecificDummy.genders)
  end

  def test_genders_reader_created
    assert_equal [0, 1], Dummy.genders.values.sort
    assert_equal %w{female male}, Dummy.genders.keys.map(&:to_s).sort
  end

  def test_that_klass_genders_return_array_of_values
    # usefuled for IN clauses
    assert_equal [0, 1], Dummy.genders(:male, :female)
    assert_equal [1, 0], Dummy.genders(:female, :male)
  end

  def test_inverted_hash_returns_synonym_by_code
    assert_equal :male, Dummy.genders.invert[0]
    assert_equal :female, Dummy.genders.invert[1]
  end

  def test_generation_of_value_shortcuts_on_class
    g = Dummy.new

    assert_equal 0, Dummy.male
    assert_equal 1, Dummy.female
    assert_equal 'alpha', Dummy.alpha
    assert_respond_to Dummy, :male
    assert_respond_to Dummy, :female
    assert_respond_to Dummy, :beta
    assert_respond_to Dummy, :foobar
  end

  def test_that_no_klass_shortcuts_are_created_if_slim_true
    with_slim = named_dummy('Dummy1') do
      as_enum :gender, [:male, :female], :slim => true
    end

    assert !with_slim.respond_to?(:male)
    assert !with_slim.respond_to?(:female)
    assert_respond_to with_slim, :genders
  end

  def test_that_no_klass_shortcuts_are_created_if_slim_class_though_instance_shortcuts_are
    with_slim_class = named_dummy('Dummy2') do
      as_enum :gender, [:male, :female], :slim => :class
    end

    jane = with_slim_class.new

    assert_respond_to jane, :male!
    assert_respond_to jane, :female!
    assert !with_slim_class.respond_to?(:male)
    assert !with_slim_class.respond_to?(:female)
    assert_respond_to with_slim_class, :genders
    assert_same 0, with_slim_class.genders.male
    assert_same 1, with_slim_class.genders[:female]
  end

  def test_that_klass_shortcuts_respect_prefix_true_and_are_prefixed_by_enum_cd
    with_prefix = named_dummy('Dummy3') do
      as_enum :gender, [:male, :female], :prefix => true
    end

    assert !with_prefix.respond_to?(:male)
    assert !with_prefix.respond_to?(:female)
    assert_respond_to with_prefix, :gender_male
    assert_respond_to with_prefix, :gender_female
    assert_equal 0, with_prefix.gender_male
    assert_respond_to with_prefix, :genders
  end

  def test_to_ensure_that_klass_shortcut_also_work_with_custom_prefixes
    with_custom_prefix = named_dummy('Dummy4') do
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

  def test_that_the_human_enum_name_method_returns_translated_humanized_values
    assert_equal :male.to_s.humanize, Dummy.human_enum_name(:genders, :male)
    assert_equal "Girl", Dummy.human_enum_name(:genders, :female)
    assert_equal "Foo", Dummy.human_enum_name(:didums, :foo)
    assert_equal "Foos", Dummy.human_enum_name(:didums, :foo, :count => 5)
  end

  def test_enum_for_select_value_class_method
    for_select = Dummy.genders_for_select(:value)
    assert_equal ["Male", 0], for_select.first
    assert_equal ["Girl", 1], for_select.last
  end
end