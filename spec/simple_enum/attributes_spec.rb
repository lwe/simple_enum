require 'spec_helper'
require 'simple_enum/attributes'

describe SimpleEnum::Attributes do

  class BooleanEnum
    def dump(x); x.to_s != 'yes' ? 0 : 1; end
    def load(x); x == 0 ? :yes : :no; end
    def keys; [:yes, :no]; end
  end

  class SimpleRubyObject
    include SimpleEnum::Attributes

    def self.types; @types ||= []; end
    def self.simple_enum_initialization_callback(type)
      self.types << type.name
      super
    end

    as_enum :gender, [:male, :female]
    as_enum :okay, BooleanEnum.new, :silly_option => true
  end

  class ExtendedRubyObject < SimpleRubyObject
    include SimpleEnum::Attributes
    as_enum :priority, { :low => '--', :medium => '-+', :high => '++', :extreme => '+++' }
  end

  context "#as_enum" do
    it "uses IndexedEnum by default" do
      type = SimpleRubyObject.simple_enum_attributes['gender']
      type.model.should be_a(SimpleEnum::IndexedEnum)
    end

    it "uses HashedEnum if a Hash is passed in" do
      type = ExtendedRubyObject.simple_enum_attributes['priority']
      type.model.should be_a(SimpleEnum::HashedEnum)
    end

    it "uses custom enum if dump, load and keys is implemented" do
      type = SimpleRubyObject.simple_enum_attributes['okay']
      type.model.should be_a(BooleanEnum)
    end

    it "passes options to type" do
      type = SimpleRubyObject.simple_enum_attributes['okay']
      type.options[:silly_option].should be_true
    end

    it "calls simple_enum_initialization_callback class method with type" do
      SimpleRubyObject.types.should == %w{gender okay}
      ExtendedRubyObject.types.should == %w{priority}
    end
  end

  context '#simple_enum_attributes' do
    it "contains 'gender' and 'okay' in SimpleRubyObject" do
      SimpleRubyObject.simple_enum_attributes.keys.sort.should == %w{gender okay}
    end

    it "contains 'gender', 'okay' and 'priority' in ExtendedRubyObject" do
      ExtendedRubyObject.simple_enum_attributes.keys.sort.should == %w{gender okay priority}
    end
  end

  context '#simple_enum_generated_class_methods' do
    before {
      SimpleRubyObject.simple_enum_generated_class_methods.module_eval do
        def my_class_method; "foo" end
      end
      ExtendedRubyObject.simple_enum_generated_class_methods.module_eval do
        def my_other_method; "bar" end
      end
    }

    it "adds my_class_method to SimpleRubyObject" do
      SimpleRubyObject.my_class_method.should == "foo"
    end

    it "inherits my_class_method to ExtendedRubyObject" do
      ExtendedRubyObject.my_class_method.should == "foo"
    end

    it "adds my_other_method to ExtendedRubyObject" do
      ExtendedRubyObject.my_other_method.should == "bar"
    end

    it "does not add my_other_method to SimpleRubyObject" do
      SimpleRubyObject.should_not respond_to(:my_other_method)
    end

    it "can be overriden by a method and invoke super" do
      class SimpleRubyObject
        def self.my_class_method; "#{super} bar" end
      end
      SimpleRubyObject.my_class_method.should == "foo bar"
    end
  end

  context '#simple_enum_generated_feature_methods' do
    before {
      SimpleRubyObject.simple_enum_generated_feature_methods.module_eval do
        def my_instance_method; "foo" end
      end
      ExtendedRubyObject.simple_enum_generated_feature_methods.module_eval do
        def my_other_method; "bar" end
      end
    }

    it "adds my_instance_method to SimpleRubyObject" do
      SimpleRubyObject.new.my_instance_method.should == "foo"
    end

    it "inherits my_instance_method to ExtendedRubyObject" do
      ExtendedRubyObject.new.my_instance_method.should == "foo"
    end

    it "adds my_other_method to ExtendedRubyObject" do
      ExtendedRubyObject.new.my_other_method.should == "bar"
    end

    it "does not add my_other_method to SimpleRubyObject" do
      SimpleRubyObject.new.should_not respond_to(:my_other_method)
    end

    it "can be overriden by a method and invoke super" do
      class SimpleRubyObject
        def my_instance_method; "#{super} bar" end
      end
      SimpleRubyObject.new.my_instance_method.should == "foo bar"
    end
  end

  context "EnumType" do
    let(:model) { SimpleEnum::IndexedEnum.new(%w{a b c}) }
    subject { SimpleEnum::EnumType.new('test', model, :some => "option") }

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
end
