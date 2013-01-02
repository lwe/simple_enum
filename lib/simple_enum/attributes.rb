require 'active_support/concern'
require 'active_support/core_ext/class'

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
      class_attribute :simple_enum_attributes, :instance_reader => false, :instance_writer => false
      self.simple_enum_attributes = {}

      extend SimpleEnum::GeneratedMethods
    end

    module ClassMethods

      # TODO add documentation
      def as_enum(name, values, options = {})
        SimpleEnum::Enum.new(name, values, options).tap do |enum|
          simple_enum_attributes[enum.name] = enum
          simple_enum_initialization_callback(simple_enum_module, enum)
        end
      end

      # Hook: This is the callback executed when `as_enum` is called, this
      # can be used by extensions to hook into the process and generate
      # alternative methods etc. Though subclasses must ensure to call `super`!
      #
      # klass - The Module used to add extensions to, it's the simple_enum_module.
      # enum - The Enum instance to initialize.
      #
      # The default implementation does nothing, nothing at all.
      #
      # Returns nothing.
      def simple_enum_initialization_callback(klass, enum)
      end

      # Private: All dynamic methods are created on this module, this ensures
      # that things like `super` still works as expected. Note that all subclasses
      # share the same module...
      #
      # It's using `module_eval` because otherwise there were issues regarding
      # the duplicate use of `ClassMethods` within module `ClassMethods.
      #
      # Returns shared module for dynamic methods.
      def simple_enum_module
        @simple_enum_module ||= Module.new.tap { |mod|
          mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            extend ActiveSupport::Concern
            module ClassMethods; end
          RUBY
          include mod
        }
      end
    end

    private

    # Public: Reads the stored value for an enumeration, can
    # be overriden by specific implementation e.g. for ActiveRecord
    # or Mongoid integration.
    #
    # attribute - The Symbol with the attribute to read.
    #
    # Returns stored value, normally a Number
    def read_enum_attribute(attribute)
      instance_variable_get("@#{attribute}")
    end

    # Public: Write attribute value for enum, just sets the instance
    # variable. Can be overriden by specific implementations, like AR
    # or Mongoid.
    #
    # attribute - The Symbol with the attribute to write.
    # value - The Number (or String) with the value to write.
    #
    # Returns nothing.
    def write_enum_attribute(attribute, value)
      instance_variable_set("@#{attribute}", value)
    end
  end
end
