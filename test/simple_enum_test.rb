require 'test_helper'

class SimpleEnumTest < ActiveSupport::TestCase
  def setup
    reload_db
  end

  test "reading public enum_definitions" do
    assert_equal "gender_cd", Dummy.enum_definitions[:gender][:column]
  end

  test "get the correct integer values when setting to symbol" do
    d = Dummy.new
    d.gender = :male
    assert_equal(0, d.gender_cd)
  end

  test "get the correct symbol when setting the integer value" do
    d = Dummy.new
    d.gender_cd = 1
    assert_equal(:female, d.gender)
  end

  test "verify that <symbol>? returns correct result" do
    d = Dummy.new
    d.gender = :male
    assert_equal(true, d.male?)
    assert_equal(false, d.female?)
  end

  test "get symbol when rows are fetched from db" do
    # Anna
    assert_equal(:female, Dummy.find(1).gender)
    assert_equal(:alpha, Dummy.find(1).word)
    assert_equal(:foo, Dummy.find(1).didum)

    # Bella
    assert_equal(true, Dummy.find(2).female?)
    assert_equal(true, Dummy.find(2).beta?)
    assert_equal(:bar, Dummy.find(2).didum)

    # Chris
    assert_equal(false, Dummy.find(3).female?)
    assert_equal(:gamma, Dummy.find(3).word)
    assert_equal(:foobar, Dummy.find(3).didum)
  end

  test "create and save new record then test symbols" do
    d = Dummy.create({ :name => 'Dummy', :gender_cd => 0 }) # :gender => male
    assert_equal(true, d.male?)

    # change :gender_cd to 1
    d.female!
    d.save!
    assert_equal(true, Dummy.find(d.id).female?)
  end

  test "validation :if" do
    class ValidateIfComputer < Computer
      set_table_name 'computers'

      validates_as_enum :manufacturer, :if => lambda { |computer|
        computer.name == "Fred"
      }
    end

    computer = ValidateIfComputer.new(:manufacturer_cd => 48328432)

    computer.name = nil
    assert_equal(true, computer.save)

    computer.name = "Fred"
    assert_equal(false, computer.save)
  end

  test "validation :unless" do
    class ValidateUnlessComputer < Computer
      set_table_name 'computers'

      validates_as_enum :manufacturer, :unless => lambda { |computer|
        computer.name == "Unless"
      }
    end

    computer = ValidateUnlessComputer.new(:manufacturer_cd => 48328432)

    computer.name = nil
    assert_equal(false, computer.save)
    assert_equal(1, computer.errors[:manufacturer].size)

    computer.name = "Unless"
    assert_equal(true, computer.save)
  end

  test "validation :on => :update" do
    class ValidateOnUpdateComputer < Computer
      set_table_name 'computers'

      validates_as_enum :manufacturer, :on => :update
    end

    computer = ValidateOnUpdateComputer.new(:manufacturer_cd => nil)
    assert_equal(true, computer.save)

    computer.name = 'Something else'
    assert_equal(false, computer.save)
    assert_equal(1, computer.errors[:manufacturer].size)
  end

  test "validation :on => :create" do
    class ValidateOnCreateComputer < Computer
      set_table_name 'computers'

      validates_as_enum :manufacturer, :on => :create
    end

    computer = ValidateOnCreateComputer.new(:manufacturer_cd => nil)
    assert_equal(false, computer.save)
    assert_equal(1, computer.errors[:manufacturer].size)

    computer.manufacturer = :apple
    assert_equal(true, computer.save)

    computer.manufacturer = nil
    assert_equal(true, computer.save)
  end

  test "validation :allow_nil" do
    class ValidateAllowNilComputer < Computer
      set_table_name 'computers'

      validates_as_enum :manufacturer, :allow_nil => true
    end

    computer = ValidateAllowNilComputer.new(:manufacturer_cd => nil)
    assert_equal(true, computer.save)

    computer.manufacturer = :apple
    assert_equal(true, computer.save)

    computer.manufacturer_cd = 84321483219
    assert_equal(false, computer.save)
    assert_equal(1, computer.errors[:manufacturer].size)
  end

  test "default error messages using translations" do
    class ValidatedComputer < Computer
      set_table_name 'computers'
      validates_as_enum :manufacturer
      validates_as_enum :operating_system
    end

    computer = ValidatedComputer.new
    assert !computer.save, "save should return false"
    assert_equal "invalid option supplied.", computer.errors[:manufacturer].first
    assert_equal "y u no os?", computer.errors[:operating_system].first
  end

  test "allow setting custom error via :message" do
    class ValidateMessageComputer < Computer
      set_table_name 'computers'
      validates_as_enum :manufacturer, :message => "invalid manufacturer"
    end

    computer = ValidateMessageComputer.new
    assert !computer.valid?, "valid? should return false"
    assert_equal "invalid manufacturer", computer.errors[:manufacturer].first
  end

  test "raises ArgumentError if invalid symbol is passed" do
    assert_raise ArgumentError do
      Dummy.new :gender => :foo
    end
  end

  test "raises NO ArgumentError if :whiny => false is defined" do
    not_whiny = Class.new(Dummy) do
      as_enum :gender, [:male, :female], :whiny => false
    end

    d = not_whiny.new :gender => :foo
    assert_nil(d.gender)
    d.gender = ''
    assert_nil(d.gender)
  end

  test "ensure that setting to 'nil' works if :whiny => true and :whiny => false" do
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

  test "deprecation warning when using enum name == column name" do
    original_behavior = ActiveSupport::Deprecation.behavior
    begin
      expected = 0
      ActiveSupport::Deprecation.silenced = false
      ActiveSupport::Deprecation.behavior = Proc.new { |msg, cb| expected += 1 if msg =~ /\[simple_enum\].+gender_cd/ }
      invalid_dummy = Class.new(ActiveRecord::Base) do
        as_enum :gender_cd, [:male, :female], :column => "gender_cd"
      end

      assert expected == 1, "deprecation message not displayed"
    ensure
      ActiveSupport::Deprecation.behavior = original_behavior
    end
  end
end
