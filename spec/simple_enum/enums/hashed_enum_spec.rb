require 'spec_helper'
require 'simple_enum/enums/hashed_enum'

describe SimpleEnum::HashedEnum do
  context 'with symbol hash keys' do
    subject { described_class.new(:male => 'M', :female => 'F') }

    it "contains :male and :female in keys" do
      subject.keys.should include(:male)
      subject.keys.should include(:female)
      subject.keys.size.should == 2
    end

    it "implements #dump" do
      subject.dump(:male).should == 'M'
      subject.dump(:female).should == 'F'
      subject.dump('male').should == 'M'
      subject.dump('female').should == 'F'
    end

    it "implements #load" do
      subject.load('M').should == :male
      subject.load('F').should == :female
    end
  end
end
