require 'test_helper'

class ScopesTest < MiniTest::Unit::TestCase
  def setup
    reload_db
  end

  def test_scopes_filter_records_to_enum_value
    assert_equal true, Dummy.vintage.all?(&:vintage?)
    assert_equal true, Dummy.modern.all?(&:modern?)
  end
end
