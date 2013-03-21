require 'spec_helper'
require 'simple_enum/attributes'

describe SimpleEnum::AttributeMethods do
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

    it "writes nil if unknown argument given" do
      subject.write_enum_attribute(:gender, :something).should == nil
      subject.read_enum_attribute(:gender).should == nil
    end
  end

  context "#enum_attribute_selected?" do
    it "compares against read_enum_attribute_before_conversion" do
      subject.should_receive(:read_enum_attribute_before_conversion).with(:gender) { 1 }
      subject.enum_attribute_selected?(:gender, :female).should be_true
    end

    it "accepts string attributes, i.e. loads value via dump()" do
      subject.write_enum_attribute(:gender, :male)
      subject.enum_attribute_selected?('gender', 'male').should be_true
    end

    it "returns false if not the selected value" do
      subject.write_enum_attribute(:gender, :male)
      subject.enum_attribute_selected?(:gender, :female).should be_false
    end

    it "returns false if value is nil" do
      subject.enum_attribute_selected?(:gender, :male).should be_false
      subject.enum_attribute_selected?(:gender, :female).should be_false
    end
  end

  context "generated feature methods" do
    context "#gender" do
      it "delegates to read_enum_attribute" do
        subject.should_receive(:read_enum_attribute).with('gender') { :female }
        subject.gender.should == :female
      end
    end

    context "#gender=" do
      it "delegates to write_enum_attribute" do
        subject.should_receive(:write_enum_attribute).with('gender', :female) { 1 }
        subject.gender = :female
      end
    end

    context "#male and #male?" do
      it "sets #male via write_enum_attribute" do
        subject.should_receive(:write_enum_attribute).with('gender', :male) { 0 }
        subject.male.should == 0
      end

      it "tests if #male? ia enum_attribute_selected?" do
        subject.should_receive(:enum_attribute_selected?).with('gender', :male) { true }
        subject.male?.should be_true
      end
    end

    context "#female and #female?" do
      it "sets #female via write_enum_attribute" do
        subject.should_receive(:write_enum_attribute).with('gender', :female) { 0 }
        subject.female.should == 0
      end

      it "tests if #female? ia enum_attribute_selected?" do
        subject.should_receive(:enum_attribute_selected?).with('gender', :female) { true }
        subject.female?.should be_true
      end
    end
  end
end
