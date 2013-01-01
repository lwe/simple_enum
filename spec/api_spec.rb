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

#  context 'active record' do
#
#    class ActiveRecordObject < ActiveRecord::Base
#      as_enum :gender, [:male, :female]
#    end
#
#    subject { ActiveRecordObject.new }
#
#    it "has default of `nil`" do
#      subject.gender.should be_nil
#      subject.gender_cd.should be_nil
#    end
#
#    it "can set gender as symbol and serializes to gender_cd" do
#      subject.gender = :male
#      subject.gender.should == :male
#      subject.gender_cd.should == 0
#    end
#
#    it "has non bang methods" do
#      subject.should_not_receive(:update_attribute)
#      subject.female
#      subject.gender.should == :female
#      subject.gender_cd.should == 1
#    end
#
#    it "has corresponding bang methods" do
#      subject.should_receive(:update_attribute, :gender_cd, 1)
#      subject.female!
#      subject.gender.should == :female
#      subject.gender_cd.should == 1
#    end
#  end
end
