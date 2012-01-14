require 'test_helper'

DirtyDummy = anonymous_dummy do
  as_enum :gender, [:male, :female], :dirty => true
end

class DirtyAttributesTest < ActiveSupport::TestCase
  def setup
    reload_db
  end

  def test_setting_using_changed_on_enum
    jane = DirtyDummy.create!(:gender => :female)
    assert_equal 1, jane.gender_cd
    jane.gender = :male # operation? =)
    assert_equal :male, jane.gender
    assert_equal true, jane.gender_cd_changed?
    assert_equal true, jane.gender_changed?
  end

  def test_access_old_value_via_gender_was
    john = DirtyDummy.create!(:gender => :male)
    assert_equal 0, john.gender_cd
    john.gender = :female
    assert_equal :female, john.gender
    assert_equal 0, john.gender_cd_was
    assert_equal :male, john.gender_was
  end

  def test_dirty_methods_are_disabled_by_default
    no_dirty = Dummy.new
    assert !no_dirty.respond_to?(:gender_was), "should not respond_to :gender_was"
    assert !no_dirty.respond_to?(:gender_changed?), "should not respond_to :gender_changed?"
    assert !no_dirty.respond_to?(:word_was), "should not respond_to :word_was"
    assert !no_dirty.respond_to?(:word_changed?), "should not respond_to :word_changed?"
  end
end