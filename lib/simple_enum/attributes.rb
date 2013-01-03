require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/hash_with_indifferent_access'

require 'simple_enum/enum'
require 'simple_enum/generated_methods'

module SimpleEnum

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

      # TODO add documentation
      def as_enum(name, values, options = {})
        SimpleEnum::Enum.new(name, values, options).tap do |enum|
          simple_enum_attributes[enum.name] = enum

          # Run callbacks
          simple_enum_class_initialization_callback(simple_enum_generated_class_methods, enum)
          simple_enum_feature_initialization_callback(simple_enum_generated_feature_methods, enum)
          enum.keys.each { |key| simple_enum_attribute_initialization_callback(simple_enum_generated_feature_methods, enum, key) }
        end
      end

      def simple_enum_class_initialization_callback(mod, enum)
      end

      def simple_enum_feature_initialization_callback(mod, enum)
      end

      def simple_enum_attribute_initialization_callback(mod, enum, key)
      end

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
      simple_enum_attributes[attribute].key(value)
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
      value = simple_enum_attributes[attribute][key] || key
      write_enum_attribute_after_conversion(attribute, value)
      value
    end

    private

    # Public: Reads the plain attribute before conversion from
    # an instance variable.
    def read_enum_attribute_before_conversion(attribute)
      instance_variable_get(:"@#{attribute}")
    end

    # Public: Writes the converted value as instance variable.
    def write_enum_attribute_after_conversion(attribute, value)
      instance_variable_set("@#{attribute}", value)
    end
  end
end
