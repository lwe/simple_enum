require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/module'

require 'simple_enum/enums'
require 'simple_enum/attribute_methods'

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

      include SimpleEnum::AttributeMethods
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
  end
end
