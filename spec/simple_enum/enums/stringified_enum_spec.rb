require 'spec_helper'
require 'simple_enum/enums/stringified_enum'

describe SimpleEnum::StringifiedEnum do
  context 'with array of strings' do
    subject { described_class.new %w{male female} }

    its(:keys) { should == %w{male female} }

    it "implements #dump" do
      subject.dump(:male).should == 'male'
      subject.dump(:female).should == 'female'
      subject.dump('male').should == 'male'
      subject.dump('female').should == 'female'
    end

    it "implements #load" do
      subject.load('male').should == 'male'
      subject.load('female').should == 'female'
    end
  end

  context 'with array of symbols' do
    subject { described_class.new [:unread, :read, :starred, :archived] }

    its(:keys) { should == [:unread, :read, :starred, :archived] }

    it "implements #dump" do
      subject.dump(:read).should == 'read'
      subject.dump('archived').should == 'archived'
      subject.dump(nil).should be_nil
    end

    it "implements #load" do
      subject.load('unread').should == :unread
      subject.load('starred').should == :starred
      subject.load(nil).should be_nil
    end
  end
end
