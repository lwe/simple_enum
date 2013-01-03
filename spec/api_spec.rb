require 'spec_helper'
require 'simple_enum/attributes'

describe 'API' do
  context 'plain old ruby object' do

    class PlainOldRubyObject
      include SimpleEnum::Attributes
      as_enum :gender, [:male, :female]
    end

    subject { PlainOldRubyObject.new }

    it "has default of `nil`" do
      subject.gender.should be_nil
    end

    it "can set gender as symbol" do
      subject.gender = :male
      subject.gender.should == :male
    end

    it "can set gender as string" do
      subject.gender = 'female'
      subject.gender.should == :female
    end

    it "can access enumeration on class" do
      subject.class.genders.should be_a(SimpleEnum::Enum)
    end
  end
end
