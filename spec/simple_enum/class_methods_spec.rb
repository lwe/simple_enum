require 'spec_helper'
require 'simple_enum/attributes'

describe SimpleEnum::ClassMethods do
  class SimpleObjectWithEnum
    include SimpleEnum::Attributes
    as_enum :gender, [:male, :female]
  end

  subject { SimpleObjectWithEnum }

  context "#genders" do
    it "returns the enum model" do
      subject.genders.should be_a(SimpleEnum::IndexedEnum)
    end

    it "returns the enum model for genders" do
      subject.genders.keys.should == [:male, :female]
    end
  end
end
