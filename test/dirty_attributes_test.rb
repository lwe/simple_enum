require 'test_helper'

class DirtyDummy < ActiveRecord::Base
  set_table_name 'dummies'
  as_enum :gender, [:male, :female]
  as_enum :word, { :alpha => 'alpha', :beta => 'beta', :gamma => 'gamma'}, :dirty => false
end

class DirtyAttributesTest < ActiveSupport::TestCase
  def setup
    reload_db
  end

  test "setting using changed? on enum" do
    jane = Dummy.create!(:gender => :female)
    assert_equal 1, jane.gender_cd
    jane.gender = :male # operation? =)
    assert_equal true, jane.gender_cd_changed?
    assert_equal true, jane.gender_changed?
  end

  test "access old value via gender_was" do
    word = Dummy.create!(:word => :beta)
    assert_equal 'beta', word.word_cd
    word.word = :alpha
    assert_equal 'beta', word.word_cd_was
    assert_equal :beta, word.word_was
  end

  test "disable dirty methods generation when :dirty == false" do
    no_dirty = DirtyDummy.new
    assert_respond_to no_dirty, :gender_was
    assert_respond_to no_dirty, :gender_changed?
    assert !no_dirty.respond_to?(:word_was), "should not respond_to :word_was"
    assert !no_dirty.respond_to?(:word_changed?), "should not respond_to :word_changed?"
  end
end