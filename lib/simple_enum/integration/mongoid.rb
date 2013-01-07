require 'active_support/concern'

require 'simple_enum/attributes'
require 'simple_enum/persistence'
require 'simple_enum/dirty'

module SimpleEnum
  module Integration
    module Mongoid
      extend ActiveSupport::Concern

      module ClassMethods

        # Internal: Hook into enum initialization to automatically create new field,
        # unless :field is set to false.
        #
        # Returns nothing.
        def simple_enum_initialization_callback(type)
          field_options = type.options[:field]
          field(type.column, !field_options || field_options == true ? {} : field_options) unless field_options == false

          super
        end
      end

      # Public: Override `update_enum_column`, because mongoid
      # has no `update_column`, but the atmoic `set` operation.
      #
      # attr_name - The String or Symbol with the num attribute to save.
      # key - The String or Symbol with the enum value to save.
      #
      # Examples:
      #
      #    instance.update_enum_column(:gender, :female)
      #    instance.gender # => :female
      #
      # Returns result of `set` operation.
      def update_enum_column(attr_name, key)
        value = write_enum_attribute(attr_name, key)
        column = simple_enum_attributes[attr_name.to_s].column
        set(column, value)
      end
    end
  end

  # The SimpleEnum::Mongoid module must be included in `Mongoid::Document` models to provide
  # `as_enum` functionality with persistence using Mongoid.
  #
  # Examples:
  #
  #   class Message
  #     include Mongoid::Document
  #     include SimpleEnum::Mongoid
  #
  #     as_enum :priority, [:low, :normal, :high, :urgent]
  #   end
  #
  module Mongoid
    extend ActiveSupport::Concern

    included do
      include SimpleEnum::Attributes
      include SimpleEnum::Persistence
      extend  SimpleEnum::Dirty
      include SimpleEnum::Integration::Mongoid
    end
  end
end
