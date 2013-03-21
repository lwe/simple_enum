require 'spec_helper'
require 'simple_enum/attributes'
require 'simple_enum/translation'
require 'simple_enum/contrib/humanize'

describe SimpleEnum::Contrib::Humanize do
  class SomeObjectWithHumanTranslations
    include SimpleEnum::Attributes
    extend SimpleEnum::Translation
    extend SimpleEnum::Contrib::Humanize

    as_enum :gender, [:male, :female]
  end

  subject { SomeObjectWithHumanTranslations.new }
  it { should respond_to(:gender_to_human) }

  it 'responds to human_enum_name' do
    SomeObjectWithHumanTranslations.should respond_to(:human_enum_name)
  end

  it "uses human_enum_name to lookup translation of current value" do
    subject.gender = :male
    SomeObjectWithHumanTranslations.should_receive(:human_enum_name).with('gender', :male) { 'm' }
    subject.gender_to_human.should == 'm'
  end

  it "returns nil if gender is not defined" do
    subject.gender_to_human.should be_nil
  end
end
