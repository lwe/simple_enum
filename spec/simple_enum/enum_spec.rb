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

    it "looks up index via []" do
      subject[:male].should == 0
      subject[:female].should == 1
    end

    it "handles reverse lookup via key()" do
      subject.key(0).should == :male
      subject.key(1).should == :female
    end
  end
end
