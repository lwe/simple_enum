require 'test_helper'
require 'simple_enum/enum_hash'

class EnumHashTest < MiniTest::Unit::TestCase

  def test_create_new_enumhash_instance_from_array_of_symbols
    genders = SimpleEnum::EnumHash.new [:male, :female]

    assert_same 0, genders[:male]
    assert_same 1, genders[:female]
    assert_same 0, genders.male
    assert_same :female, genders.female(true)
  end

  def test_create_new_enumhash_instance_from_hash
    status = SimpleEnum::EnumHash.new :inactive => 0, :active => 1, :archived => 99

    assert_same 0, status.inactive
    assert_same 1, status[:active]
  end

  def test_create_new_enumhash_instance_from_query_results
    reload_db :genders => true
    genders = SimpleEnum::EnumHash.new Gender.all

    assert_same 0, genders[@male]
    assert_same genders[@male], genders[:male]
    assert_same 1, genders.female
    assert_equal @male, genders.send(:male, true)
  end

  def test_that_enumhash_keys_are_ordered
    ordered = SimpleEnum::EnumHash.new [:alpha, :beta, :gamma, :delta, :epsilon, :zeta, :eta]
    expected_keys = [:alpha, :beta, :gamma, :delta, :epsilon, :zeta, :eta]
    assert_equal expected_keys, ordered.keys
  end

  def test_valid_key_value_association_when_simple_array_is_merged_into_enumhash
    a = [:a, :b, :c, :d]
    h = SimpleEnum::EnumHash.new(a)

    assert_same 0, h[:a]
    assert_same 1, h[:b]
    assert_same 2, h[:c]
    assert_same 3, h[:d]
    assert_equal [:a, :b, :c, :d], h.keys
  end

  def test_that_an_already_correct_looking_array_is_converted_to_hash
    a = [[:a, 5], [:b, 10]]
    h = SimpleEnum::EnumHash.new(a)

    assert_same 5, h[:a]
    assert_same 10, h[:b]
    assert_equal [:a, :b], h.keys
  end

  def test_that_an_array_of_query_results_are_converted_to_result_ids
    reload_db :genders => true # reload db
    a = Gender.all

    h = SimpleEnum::EnumHash.new(a)

    assert_same 0, h[@male]
    assert_same 1, h[@female]
  end

  def test_strings_option
    h = SimpleEnum::EnumHash.new([:male, :female], true)
    assert_equal "male", h[:male]
    assert_equal "female", h[:female]
  end
end
