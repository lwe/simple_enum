require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/module'
require 'active_support/hash_with_indifferent_access'

require 'simple_enum/indexed_enum'
require 'simple_enum/generated_methods'

module SimpleEnum

  EnumAttribute = Struct.new(:name, :enum, :options) do
    delegate :dump, :load, :keys, :to => :enum

    def prefix
      @prefix ||= options[:prefix] && "#{options[:prefix] == true ? name : options[:prefix]}_"
    end

    def column
      @column ||= options[:column] || "#{name}_cd".to_sym
    end
  end

  # The SimpleEnum::Attributes is the core module which provides the `as_enum`
  # call and all basic functions so that enumerations can be added, loaded set
  # etc.
  #
  # TODO write documentation
  module Attributes
    extend ActiveSupport::Concern

    included do
      # TODO write documentation
      class_attribute :simple_enum_attributes, :instance_writer => false
      self.simple_enum_attributes = HashWithIndifferentAccess.new

      extend SimpleEnum::GeneratedMethods
    end

    module ClassMethods

      # Public: Creates a new enumerated attribute on the current class.
      def as_enum(name, values, options = {})
        enum = SimpleEnum::IndexedEnum.new(values)
        attribute = SimpleEnum::EnumAttribute.new(name, enum, options)
        simple_enum_initialization_callback(attribute)
        self.simple_enum_attributes = simple_enum_attributes.merge(name => attribute)
      end

      # Provided initialization hooks/callbacks.
      def simple_enum_initialization_callback(attribute); end

      def simple_enum_generated_class_methods
        @simple_enum_generated_class_methods ||= Module.new.tap { |mod|
          extend mod
        }
      end

      def simple_enum_generated_feature_methods
        @simple_enum_generated_feature_methods ||= Module.new.tap { |mod|
          include mod
        }
      end
    end

    # Public: Reads the stored value for an enumeration and converts
    # it to the enumerated value. Integrations for ActiveRecord or
    # Mongoid should override `read_enum_attribute_before_conversion`
    # instead.
    #
    # attribute - The Symbol with the attribute to read.
    #
    # Returns stored value, normally a Number
    def read_enum_attribute(attribute)
      value = read_enum_attribute_before_conversion(attribute)
      simple_enum_attributes[attribute].load(value)
    end

    # Public: Write attribute value for enum, converts the key to
    # the enum value and delegates to `write_enum_attribute_after_conversion`
    # which integrations like AR/Mongoid can override
    #
    # attribute - The Symbol with the attribute to write.
    # key - The Symbol with the value to write.
    #
    # Returns stored and converted value.
    def write_enum_attribute(attribute, key)
      value = simple_enum_attributes[attribute].dump(key) || key
      write_enum_attribute_after_conversion(attribute, value)
      value
    end

    private

    # Public: Reads the plain attribute before conversion from
    # an instance variable.
    #
    # Returns enumeration before
    def read_enum_attribute_before_conversion(attribute)
      instance_variable_get(:"@#{attribute}")
    end

    # Public: Writes the converted value as instance variable.
    def write_enum_attribute_after_conversion(attribute, value)
      instance_variable_set("@#{attribute}", value)
    end
  end
end
