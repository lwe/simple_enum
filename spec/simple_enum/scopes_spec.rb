require 'spec_helper'
require 'simple_enum/scopes'

describe SimpleEnum::Scopes do
  class SomeObjectWithScopesOption
    include SimpleEnum::Attributes
    extend SimpleEnum::Scopes

    as_enum :gender, [:male, :female], :scopes => true
  end

  class SomeObjectWithoutScopesOption
    include SimpleEnum::Attributes
    extend SimpleEnum::Scopes

    as_enum :gender, [:male, :female]
  end

  context "with scopes option" do
    subject { SomeObjectWithScopesOption }

    it { should respond_to(:males) }
    it { should respond_to(:females) }

    it "uses where method to find objects" do
      SomeObjectWithScopesOption.should_receive(:where).with({:gender_cd =>0}) { [] }
      SomeObjectWithScopesOption.males.should == []
    end
  end

  context "without scopes option" do
    subject { SomeObjectWithoutScopesOption }

    it { should_not respond_to(:males) }
    it { should_not respond_to(:females) }
  end
end
