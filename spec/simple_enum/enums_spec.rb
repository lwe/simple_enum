require 'spec_helper'
require 'simple_enum/enums'

describe 'SimpleEnum::Enum factory method' do
  let(:existing_enum) { SimpleEnum::IndexedEnum.new(%w{a b c}) }

  it 'returns IndexedEnum given a string array' do
    enum = SimpleEnum::Enum(%w{a b c})
    enum.should be_a(SimpleEnum::IndexedEnum)
    enum.keys.should == %w{a b c}
  end

  it 'returns IndexedEnum given a symbol array' do
    enum = SimpleEnum::Enum [:alpha, :beta, :gamma]
    enum.should be_a(SimpleEnum::IndexedEnum)
    enum.keys.should == [:alpha, :beta, :gamma]
  end

  it 'returns HashedEnum given a hash' do
    enum = SimpleEnum::Enum(:alpha => 'A', :beta => 'B')
    enum.should be_a(SimpleEnum::HashedEnum)
    enum.keys.map { |k| k.to_s }.sort.should == %w{alpha beta}
  end

  it 'can choose the implemention by passing in third argument' do
    enum = SimpleEnum::Enum([:alpha, :beta, :gamma], :stringified)
    enum.should be_a(SimpleEnum::StringifiedEnum)
    enum.keys.map { |k| k.to_s }.sort.should == %w{alpha beta gamma}
  end

  it 'returns values if given an object which implements #load, #dump and #keys' do
    enum = SimpleEnum::Enum(existing_enum)
    enum.should be_a(SimpleEnum::IndexedEnum)
    enum.should == existing_enum
  end

  it 'ignores the factory if a enum is passed' do
    enum = SimpleEnum::Enum(existing_enum, :hashed)
    enum.should be_a(SimpleEnum::IndexedEnum)
    enum.should == existing_enum
  end
end
