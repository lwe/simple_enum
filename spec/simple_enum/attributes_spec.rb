require 'spec_helper'
require 'simple_enum/attributes'

describe SimpleEnum::Attributes do
  class PlainOldRubyObject
    include SimpleEnum::Attributes
    as_enum :gender, [:male, :female]
  end

  subject { PlainOldRubyObject.new }

  context "#read_enum_attribute" do
    it "delegates to read_enum_attribute_before_conversion to get converted value" do
      subject.should_receive(:read_enum_attribute_before_conversion).with(:gender) { 1 }
      subject.read_enum_attribute(:gender).should == :female
    end

    it "returns nil if not set" do
      subject.read_enum_attribute(:gender).should be_nil
    end

    it "returns key" do
      subject.should_receive(:read_enum_attribute_before_conversion).with(:gender) { 0 }
      subject.read_enum_attribute(:gender).should == :male
    end

    it "returns key when called with string attribute" do
      subject.should_receive(:read_enum_attribute_before_conversion).with('gender') { 0 }
      subject.read_enum_attribute('gender').should == :male
    end
  end

  context "#write_enum_attribute" do
    it "delegates to write_enum_attribute_after_conversion with converted value" do
      subject.should_receive(:write_enum_attribute_after_conversion).with(:gender, 1)
      subject.write_enum_attribute(:gender, :female)
    end

    it "returns converted value" do
      subject.write_enum_attribute(:gender, :female).should == 1
    end

    it "returns converted value when called with string attributes" do
      subject.write_enum_attribute('gender', 'female').should == 1
    end

    it "accepts numerical argument" do
      subject.write_enum_attribute(:gender, 1).should == 1
      subject.read_enum_attribute(:gender).should == :female
    end
  end

  context "generated class methods" do
    subject { PlainOldRubyObject }
    its(:genders) { should be_a(SimpleEnum::IndexedEnum) }
    its(:genders) { should respond_to(:load) }
    its(:genders) { should respond_to(:dump) }

    it "has :male and :female as keys" do
      subject.genders.keys.should == [:male, :female]
    end
  end

  context "generated feature methods" do
    context "#gender" do
    end

    context "#gender=" do
    end

    context "#male and #male?" do
    end

    context "#female and #female?" do
    end
  end
end
