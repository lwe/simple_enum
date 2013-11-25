require 'test_helper'

class SimpleEnumTest < MiniTest::Unit::TestCase
  def setup
    reload_db
  end

  def test_reading_public_enum_definitions
    assert_equal "gender_cd", Dummy.enum_definitions[:gender][:column]
  end

  def test_enum_definitions_only_available_from_class
    assert_raises(NoMethodError) { Dummy.new.enum_definitions }
    assert_raises(NoMethodError) { Dummy.new.enum_definitions= {} }
  end

  def test_enum_definitions_local_to_model
    assert_equal nil, Computer.enum_definitions[:gender]
  end

  def test_getting_the_correct_integer_values_when_setting_to_symbol
    d = Dummy.new
    d.gender = :male
    assert_equal(0, d.gender_cd)
  end

  def test_getting_the_correct_symbold_when_setting_the_integer_value
    d = Dummy.new
    d.gender_cd = 1
    assert_equal(:female, d.gender)
  end

  def test_that_checker_returns_correct_result
    d = Dummy.new
    d.gender = :male
    assert_equal(true, d.male?)
    assert_equal(false, d.female?)
  end

  def test_setting_value_as_key
    d = Dummy.new
    d.gender = 1
    assert_equal(:female, d.gender)
    assert_equal(1, d.gender_cd)
  end

  def test_setting_value_when_it_is_not_a_string_and_strings_is_true
    d = Dummy.new    
    d.numeric = 100
    assert_equal(:"100", d.numeric)
    assert_equal("100", d.numeric_cd)
    d.numeric = 3.14
    assert_equal(:"3.14", d.numeric)
    assert_equal("3.14", d.numeric_cd)
  end

  def test_setting_value_to_nil_when_enum_has_nil_as_symbol_and_strings_is_true
    d = Dummy.new
    d.nilish = nil
    assert_equal(nil, d.nilish)
    assert_equal(nil, d.nilish_cd)
  end

  def test_setting_value_as_key_in_constructor
    d = Dummy.new :gender => 1
    assert_equal(:female, d.gender)
    assert_equal(1, d.gender_cd)
  end

  def test_enum_comparisons
    d = Dummy.new
    assert_equal(false, d.gender?)
    d.gender = :male
    assert_equal(true, d.gender?)
    assert_equal(true, d.gender?(:male))
    assert_equal(false, d.gender?(:female))
    assert_equal(false, d.gender?(:whot))
    d.gender = :female
    assert_equal(true, d.gender?(:female))
    assert_equal(false, d.gender?(:male))
  end

  def test_enum_comparisons_with_strings
    d = Dummy.new(:gender => :male)
    assert_equal(true, d.gender?("male"))
  end

  def test_enum_comparisons_with_nil_always_returns_false
    d = Dummy.new(:gender => :male)
    assert_equal(false, d.gender?(nil))
  end

  def test_getting_symbol_when_data_is_fetched_from_datasource
    dummies = Dummy.all

    # Anna
    assert_equal(:female, dummies[0].gender)
    assert_equal(:alpha, dummies[0].word)
    assert_equal(:foo, dummies[0].didum)

    # Bella
    assert_equal(true, dummies[1].female?)
    assert_equal(true, dummies[1].beta?)
    assert_equal(:bar, dummies[1].didum)

    # Chris
    assert_equal(false, dummies[2].female?)
    assert_equal(:gamma, dummies[2].word)
    assert_equal(:foobar, dummies[2].didum)
  end

  def test_creating_and_saving_a_new_datasource_object_then_test_symbols
    d = Dummy.create({ :name => 'Dummy', :gender_cd => 0 }) # :gender => male
    assert_equal(true, d.male?)

    # change :gender_cd to 1
    d.female!
    d.save!
    assert_equal(true, Dummy.find(d.id).female?)
  end

  def test_validation_if
    validate_if_comp = extend_computer do
      validates_as_enum :manufacturer, :if => lambda { |computer|
        computer.name == "Fred"
      }
    end

    computer = validate_if_comp.new(:manufacturer_cd => 48328432)

    computer.name = nil
    assert_equal(true, computer.save)

    computer.name = "Fred"
    assert_equal(false, computer.save)
  end

  def test_validation_unless
    validate_unless_comp = extend_computer do
      validates_as_enum :manufacturer, :unless => lambda { |computer|
        computer.name == "Unless"
      }
    end

    computer = validate_unless_comp.new(:manufacturer_cd => 48328432)

    computer.name = nil
    assert_equal(false, computer.save)
    assert_equal(1, computer.errors[:manufacturer].size)

    computer.name = "Unless"
    assert_equal(true, computer.save)
  end

  def test_validation_on_update
    validate_update_comp = extend_computer do
      validates_as_enum :manufacturer, :on => :update
    end

    computer = validate_update_comp.new(:manufacturer_cd => nil)
    assert_equal(true, computer.save)

    computer.name = 'Something else'
    assert_equal(false, computer.save)
    assert_equal(1, computer.errors[:manufacturer].size)
  end

  def test_validation_on_create
    validate_create_comp = extend_computer do
      validates_as_enum :manufacturer, :on => :create
    end

    computer = validate_create_comp.new(:manufacturer_cd => nil)
    assert_equal(false, computer.save)
    assert_equal(1, computer.errors[:manufacturer].size)

    computer.manufacturer = :apple
    assert_equal(true, computer.save)

    computer.manufacturer = nil
    assert_equal(true, computer.save)
  end

  def test_validation_allow_nil
    validate_nil_comp = extend_computer do
      validates_as_enum :manufacturer, :allow_nil => true
    end

    computer = validate_nil_comp.new(:manufacturer_cd => nil)
    assert_equal(true, computer.save)

    computer.manufacturer = :apple
    assert_equal(true, computer.save)

    computer.manufacturer_cd = 84321483219
    assert_equal(false, computer.save)
    assert_equal(1, computer.errors[:manufacturer].size)
  end

  def test_default_error_messages_using_translations
    validated_comp = extend_computer("ValidatedComputer") do
      validates_as_enum :manufacturer
      validates_as_enum :operating_system
    end

    computer = validated_comp.new
    assert !computer.save, "save should return false"
    assert_equal "invalid option supplied", computer.errors[:manufacturer].first
    assert_equal "y u no os?", computer.errors[:operating_system].first
  end

  def test_allow_setting_custom_error_via_message
    validate_msg_comp = extend_computer do
      validates_as_enum :manufacturer, :message => "invalid manufacturer"
    end

    computer = validate_msg_comp.new
    assert !computer.valid?, "valid? should return false"
    assert_equal "invalid manufacturer", computer.errors[:manufacturer].first
  end

  def test_validator
    validator_comp = extend_computer do
      validates :manufacturer, :operating_system, :as_enum => true
    end

    computer = validator_comp.new
    assert !computer.save, "save should return false"
    assert_equal(1, computer.errors[:manufacturer].size)
    assert_equal(1, computer.errors[:operating_system].size)

    computer.manufacturer_cd = 84321483219
    assert !computer.save, "save should return false"
    assert_equal(1, computer.errors[:manufacturer].size)

    computer.manufacturer_cd = 0
    computer.operating_system_cd = 0
    assert_equal(true, computer.save)
  end

  def test_validator_allows_symbols_as_raw_colum_value_if_strings_is_true
    validated_dummy = extend_dummy do
      validates_as_enum :role
    end

    d = validated_dummy.new :role_cd  => :admin
    assert d.valid?, "valid? should return true"
  end

  def test_that_argumenterror_is_raised_if_invalid_symbol_is_passed
    assert_raises ArgumentError do
      Dummy.new :gender => :foo
    end
  end

  def test_that_no_argumenterror_is_raised_if_whiny_is_false
    not_whiny = Class.new(Dummy) do
      as_enum :gender, [:male, :female], :whiny => false
    end

    d = not_whiny.new :gender => :foo
    assert_nil(d.gender)
    d.gender = ''
    assert_nil(d.gender)
  end

  def test_that_setting_to_nil_works_if_whiny_is_true_or_false
    d = Dummy.new :gender => :male
    assert_equal(:male, d.gender)
    d.gender = nil
    assert_nil(d.gender)
    d.gender = ''
    assert_nil(d.gender)

    not_whiny_again = Class.new(Dummy) do
      as_enum :gender, [:male, :female], :whiny => false
    end

    d = not_whiny_again.new :gender => :male
    assert_equal(:male, d.gender)
    d.gender = nil
    assert_nil(d.gender)
    d.gender = ''
    assert_nil(d.gender)
  end

  def test_argument_error_is_raised_when_using_enum_name_eq_column_name
    begin
      invalid_dummy = anonymous_dummy do
        as_enum :gender_cd, [:male, :female], :column => "gender_cd"
      end
      assert false, "no error raised"
    rescue ArgumentError => e
      assert e.to_s =~ /use different names for/, "invalid ArgumentError raised"
    end
  end

  def test_human_name_for_nil_value
    d = Dummy.new
    assert_nil(d.human_gender)
  end

  def test_strings_option
    d = Dummy.new :role => :anon

    assert_equal :anon, d.role
    assert_equal 'anon', d.role_cd

    d.role = :admin

    assert_equal :admin, d.role
    assert_equal 'admin', d.role_cd
  end
end
