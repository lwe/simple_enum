require 'test_helper'

class POROTest < MiniTest::Unit::TestCase
  class MyPORO
    include SimpleEnum

    attr_accessor :gender_cd
    as_enum :gender, [:male, :female]
  end

  def test_reading_and_writing
    poro = POROTest::MyPORO.new
    poro.gender_cd = 1
    assert_equal :female, poro.gender

    poro.male!
    assert_equal 0, poro.gender_cd
    assert_equal :male, poro.gender
  end
end