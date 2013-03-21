require 'spec_helper'
require 'active_model/naming'
require 'active_model/translation'
require 'simple_enum/translation'

describe SimpleEnum::Translation do
  class SomeObjectWithTranslation
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    extend SimpleEnum::Translation
  end

  before do
    I18n.reload!
    I18n.locale = :en
  end

  subject { SomeObjectWithTranslation }
  it { should respond_to(:human_enum_name) }

  it "looks up translation by model and attribute name" do
    store_translation "activemodel.enums.some_object_with_translation.genders.female", "Women"
    subject.human_enum_name(:gender, :female).should == "Women"
  end

  it "looks up translation by model" do
    store_translation "activemodel.enums.some_object_with_translation.male", "Men"
    subject.human_enum_name(:gender, :male).should == "Men"
  end

  it "looks up translation in enums namespace with attribute name" do
    store_translation "enums.genders.male", "Men Y"
    subject.human_enum_name(:gender, :male).should == "Men Y"
  end

  it "looks up translation in enums namespace" do
    store_translation "enums.female", "Women X"
    subject.human_enum_name(:gender, :female).should == "Women X"
  end

  it "can override default using :default" do
    subject.human_enum_name(:gender, :female, :default => "Women").should == "Women"
  end

  it "falls back to `humanize` if no translation is found" do
    subject.human_enum_name(:gender, :female).should == "Female"
  end

  it "passes remaining arguments directly to I18n.translate" do
    store_translation "enums.female", "Women %{count} %{didum}"
    subject.human_enum_name(:gender, :female, :didum => "DIDUM").should == "Women 1 DIDUM"
  end

  # Helper method to store translations in I18n::Backends::Simple using a string.
  def store_translation(path, value, locale = :en)
    parts = path.to_s.split('.')
    hash = Hash[parts.pop, value]
    parts.reverse.each { |key| hash = Hash[key, hash] }

    I18n.backend.store_translations locale, hash
  end
end
