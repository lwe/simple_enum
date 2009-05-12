require 'test_helper'

class Dummy < ActiveRecord::Base
  as_enum :gender, [:male, :female]
  as_enum :word, { :alpha => 'alpha', :beta => 'beta', :gamma => 'gamma'}
  as_enum :didum, [ :foo, :bar, :foobar ], :column => 'other'
end

class SimpleEnumTest < ActiveSupport::TestCase  
  def setup
    ActiveRecord::Base.connection.create_table :dummies, :force => true do |t|
      t.column :name, :string
      t.column :gender_cd, :integer
      t.column :word_cd, :string, :limit => 5
      t.column :other, :integer
    end
    
    # fill db with some rows
    Dummy.create({ :name => 'Anna',  :gender_cd => 1, :word_cd => 'alpha', :other => 0})
    Dummy.create({ :name => 'Bella', :gender_cd => 1, :word_cd => 'beta', :other => 1})
    Dummy.create({ :name => 'Chris', :gender_cd => 0, :word_cd => 'gamma', :other => 2})
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
end
