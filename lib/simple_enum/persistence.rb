require 'active_support/concern'

module SimpleEnum

  # The Persistence module provides integration with the persistence tier, by overriding
  # `read_enum_attribute_before_conversion` and `write_enum_attribute_after_conversion`.
  # These methods are implemented using `read_attribute` and `write_attribute` as generally
  # provided by persistence layers like ActiveRecord or Mongoid. Furthermore it also creates
  # a corresponding _bang_ method to write an enum to the storage.
  #
  # Examples:
  #
  #    class Message
  #      include Mongoid::Document
  #      include SimpleEnum::Mongoid
  #      as_enum :priority, [:low, :medium, :high]
  #    end
  #
  #    message.create(:priority => :medium)
  #    message.medium? # => true
  #    message.low! # (persisted)
  #
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods

      # Public: Create the _bang_ methods for each enum key, they basically
      # delegate to `update_enum_column`.
      #
      # Must call super (and it does).
      def simple_enum_initialization_callback(type)
        type.keys.each do |key|
          simple_enum_generated_feature_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{type.prefix}#{key}!                                   # def female!
              update_enum_column(#{type.name.inspect}, #{key.inspect})  #   update_enum_column('genders', :female)
            end                                                         # end
          RUBY
        end

        super
      end
    end

    # Public: Method similar to `update_column` which changes the enum value and
    # stores the change in the persistence tier using `update_column` - so the
    # persistence layer must provide a method named `update_column`.
    #
    # attr_name - The String or Symbol with the enum attribute name.
    # key - The String or Symbol with the enumeration key to save.
    #
    # Returns result of `update_column`.
    def update_enum_column(attr_name, key)
      value = write_enum_attribute(attr_name, key)
      column = simple_enum_attributes[attr_name.to_s].column
      update_column(column, value)
    end

    private

    # Internal: Override original behavior by delegating to `read_attribute`
    # using the column name of the attribute.
    def read_enum_attribute_before_conversion(attr_name)
      read_attribute(simple_enum_attributes[attr_name.to_s].column)
    end

    # Internal: Override original behavior by delegating to write_attribute
    # using the column name of the attribute.
    def write_enum_attribute_after_conversion(attr_name, value)
      write_attribute(simple_enum_attributes[attr_name.to_s].column, value)
    end
  end
end
