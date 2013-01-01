require 'active_support/concern'
require 'active_support/core_ext/class'

require 'simple_enum/enum'
require 'simple_enum/generated_methods'

module SimpleEnum

  # The SimpleEnum::Attributes is the core module which provides the `as_enum`
  # call and all basic functions so that enumerations can be added, loaded set
  # etc.
  #
  module Attributes
    extend ActiveSupport::Concern

    included do
      class_attribute :simple_enum_attributes, :instance_reader => false, :instance_writer => false
      self.simple_enum_attributes = {}

      extend SimpleEnum::GeneratedMethods
      include simple_enum_module
    end

    module ClassMethods
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

    private

      # Private: All dynamic methods are created on this module, this ensures
      # that things like `super` still works as expected. Note that all subclasses
      # share the same module...
      #
      # It's using `module_eval` because otherwise there were issues regarding
      # the duplicate use of `ClassMethods` within module `ClassMethods.
      #
      # Returns shared module for dynamic methods.
      def simple_enum_module
        @simple_enum_module ||= Module.new.tap { |m|
          m.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            extend ActiveSupport::Concern
            module ClassMethods; end
          RUBY
        }
      end
    end

    private

    def read_enum_attribute(attribute)
      instance_variable_get("@#{attribute}")
    end

    def write_enum_attribute(attribute, value)
      instance_variable_set("@#{attribute}", value)
    end

    def enum_attribute?(attribute, value)
      read_enum_attribute(attribute) == value
    end
  end
end
