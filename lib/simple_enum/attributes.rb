require 'active_support/concern'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'

require 'simple_enum/enums'
require 'simple_enum/enum_type'
require 'simple_enum/attribute_methods'

module SimpleEnum

  # Public: The default_options are always merged with the options
  # provided in `as_enum`. It allows to set some defaults, e.g. like always
  # enabling the prefix. The options are deep merged.
  #
  # Examples:
  #
  #   # config/initializiers/simple_enum.rb or similar
  #   # Always enable prefixes
  #   SimpleEnum.default_options[:prefix] = true
  #
  # Returns a Hash.
  def self.default_options
    @default_options ||= {}
  end

  # The SimpleEnum::Attributes is the core module which provides the `as_enum`
  # call and all basic functionality - this is also the module that must be
  # included to enable simple_enum for a class.
  #
  # Examples:
  #
  #    class Message
  #      include SimpleEnum::Attributes
  #      as_enum :priority, [:low, :medium, :high]
  #    end
  #
  #    msg = Message.new
  #    msg.priority = :medium
  #    msg.high? # => false
  #
  module Attributes
    extend ActiveSupport::Concern

    included do
      # Holds all enum attributes on this class, provides an instance reader.
      # It is a Hash of EnumType instances and the enum name as String key.
      class_attribute :simple_enum_attributes, :instance_writer => false
      self.simple_enum_attributes = {}

      # Generate default attribute methods (setter/getter et all).
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
      #
      # Returns EnumType instance.
      def as_enum(attr_name, values, options = {})
        values = SimpleEnum::Enum(values)
        options = SimpleEnum.default_options.deep_merge(options)

        SimpleEnum::EnumType.new(attr_name.to_s, values, options).tap do |type|
          simple_enum_initialization_callback(type)
          self.simple_enum_attributes = simple_enum_attributes.merge(type.name => type)
        end
      end

      # Provided initialization hooks/callbacks.
      def simple_enum_initialization_callback(type); end

      # Public: Access a dynamically extended and generated module to
      # add class methods, new dynamically generated class methods should
      # be added only via this module.
      #
      # Returns Module.
      def simple_enum_generated_class_methods
        @simple_enum_generated_class_methods ||= Module.new.tap { |mod|
          extend mod
        }
      end

      # Public: Access a dynamically extended and generated module to
      # add instance methods, new dynamically generated instance methods should
      # be added only via this module.
      #
      # Returns Module.
      def simple_enum_generated_feature_methods
        @simple_enum_generated_feature_methods ||= Module.new.tap { |mod|
          include mod
        }
      end
    end
  end
end
