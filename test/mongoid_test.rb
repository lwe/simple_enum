require 'test_helper'

class MongoidTest < MiniTest::Unit::TestCase
  def setup
    reload_db
  end

  def test_creates_a_field_per_default
    skip('Only available in mongoid') unless mongoid?
    klass = anonymous_dummy do
      as_enum :gender, [:male, :female]
    end
    refute_nil klass.new.fields['gender_cd']
  end

  def test_passing_custom_field_options
    skip('Only available in mongoid') unless mongoid?
    klass = anonymous_dummy do
      field :verify, :type => Integer
      as_enum :gender, [:male, :female], :field => { :type => Integer, :default => 1 }
    end

    gender_field = klass.new.fields['gender_cd']
    refute_nil gender_field
    assert_equal 1, gender_field.default
    assert_equal klass.fields['verify'].class, gender_field.class
    assert_equal :female, klass.new.gender
  end

  def test_skip_field_creation_if_field_false
    skip('Only available in mongoid') unless mongoid?
    klass = anonymous_dummy do
      as_enum :gender, [:male, :female], :field => false
    end

    assert_nil klass.new.fields['gender_cd']
  end
end