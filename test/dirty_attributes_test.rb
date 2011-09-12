require 'test_helper'

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
end