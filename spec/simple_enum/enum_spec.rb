require 'spec_helper'
require 'simple_enum/enum'

describe SimpleEnum::Enum do
  context 'name as string' do
    subject { described_class.new 'gender', %w{male female} }
    its(:name) { should == :gender }
  end

  context 'with array of strings' do
    subject { described_class.new :gender, %w{male female} }

    its(:name) { should == :gender }
    its(:prefix) { should be_nil }
    its(:keys) { should == [:male, :female] }
    its(:values) { should == [0, 1] }
  end
end
