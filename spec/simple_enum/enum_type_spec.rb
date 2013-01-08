require 'spec_helper'
require 'simple_enum/enum_type'
require 'simple_enum/enums/indexed_enum'

describe SimpleEnum::EnumType do
  let(:model) { SimpleEnum::IndexedEnum.new(%w{a b c}) }
  subject { SimpleEnum::EnumType.new(:test, model, :some => "option") }

  its(:name) { should == 'test' }
  its(:model) { should == model }
  its(:options) { should == { :some => "option" } }

  context "#prefix" do
    it "defaults to nil" do
      subject.prefix.should be_nil
    end

    it "prefixes the name if :prefix is true" do
      subject.options[:prefix] = true
      subject.prefix.should == 'test_'
    end

    it "prefixes the supplied string otherwise" do
      subject.options[:prefix] = 'custom'
      subject.prefix.should == 'custom_'
    end
  end

  context "#column" do
    it "defaults to {{attr_name}}_cd" do
      subject.column.should == "test_cd"
    end

    it "can be overriden by setting :column option" do
      subject.options[:column] = 'some_column'
      subject.column.should == 'some_column'
    end
  end
end
