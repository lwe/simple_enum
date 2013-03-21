require 'spec_helper'
require 'simple_enum/enums/indexed_enum'

describe SimpleEnum::IndexedEnum do
  context 'with array of strings' do
    subject { described_class.new %w{male female} }

    its(:keys) { should == %w{male female} }

    it "implements #dump" do
      subject.dump(:male).should == 0
      subject.dump(:female).should == 1
      subject.dump('male').should == 0
      subject.dump('female').should == 1
    end

    it "implements #load" do
      subject.load(0).should == 'male'
      subject.load(1).should == 'female'
    end
  end

  context 'with array of symbols' do
    subject { described_class.new [:unread, :read, :starred, :archived] }

    its(:keys) { should == [:unread, :read, :starred, :archived] }

    it "implements #dump" do
      subject.dump(:read).should == 1
      subject.dump('archived').should == 3
      subject.dump(nil).should be_nil
    end

    it "implements #load" do
      subject.load(0).should == :unread
      subject.load(2).should == :starred
      subject.load(nil).should be_nil
    end
  end
end
