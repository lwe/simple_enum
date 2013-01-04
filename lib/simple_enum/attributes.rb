require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/module'
require 'active_support/hash_with_indifferent_access'

require 'simple_enum/indexed_enum'
require 'simple_enum/generated_methods'

module SimpleEnum

  # The EnumType encapsulates all information for an enum instance,
  # including the name, options and the coder/values.
  EnumType = Struct.new(:name, :model, :options) do
    # Simplified access to #load, #dump and #keys on model.
    delegate :dump, :load, :keys, :to => :model

    # Returns String with prefix for methods, if any.
    def prefix
      @prefix ||= options[:prefix] && "#{options[:prefix] == true ? name : options[:prefix]}_"
    end

    # Returns String with column name, or `options[:column]`.
    def column
      @column ||= options[:column] || "#{name}_cd"
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
      self.simple_enum_attributes = {}

      extend SimpleEnum::GeneratedMethods
    end

    module ClassMethods

      # Public: Creates a new enumerated attribute on the current class and
      # generates all dynamic methods. Enumerated attribute are attributes
      # that can only a previously known possible values, useful for things
      # like relationship status, gender etc.
      #
      # attr_name - The Symbol or String with the name of the enumeration.
      # values - The Array, Hash or anything that implements #load, #dump and
      #          #keys. Contains the available enumeration values.
      def as_enum(attr_name, values, options = {})
        values = if [:load, :dump, :keys].all? { |m| values.respond_to?(m) }
          values
        elsif values.is_a?(Hash)
          SimpleEnum::HashedEnum.new(values)
        else
          SimpleEnum::IndexedEnum.new(values)
        end

        SimpleEnum::EnumType.new(attr_name.to_s, values, options).tap do |type|
          simple_enum_initialization_callback(type)
          self.simple_enum_attributes = simple_enum_attributes.merge(type.name => type)
        end
      end

      # Provided initialization hooks/callbacks.
      def simple_enum_initialization_callback(type); end

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
    # attr_name - The Symbol with the attribute to read.
    #
    # Returns stored value, normally a Number
    def read_enum_attribute(attr_name)
      value = read_enum_attribute_before_conversion(attr_name)
      simple_enum_attributes[attr_name.to_s].load(value)
    end

    # Public: Write attribute value for enum, converts the key to
    # the enum value and delegates to `write_enum_attribute_after_conversion`
    # which integrations like AR/Mongoid can override
    #
    # attr_name - The Symbol with the attribute to write.
    # key - The Symbol with the value to write.
    #
    # Returns stored and converted value.
    def write_enum_attribute(attr_name, key)
      value = simple_enum_attributes[attr_name.to_s].dump(key)
      write_enum_attribute_after_conversion(attr_name, value)
      value
    end

    private

    # Public: Reads the plain attribute before conversion from
    # an instance variable.
    #
    # Returns enumeration before
    def read_enum_attribute_before_conversion(attr_name)
      instance_variable_get(:"@#{attr_name}")
    end

    # Public: Writes the converted value as instance variable.
    def write_enum_attribute_after_conversion(attr_name, value)
      instance_variable_set("@#{attr_name}", value)
    end
  end
end
