require 'active_support/concern'

module SimpleEnum
  module Persistence
    extend ActiveSupport::Concern

    module ClassMethods
      def simple_enum_initialization_callback(type)
        type.keys.each do |key|
          simple_enum_generated_feature_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{type.prefix}#{key}!                                   # def female!
              update_enum_column(#{type.name.inspect}, #{key.inspect})  #   update_enum_column(:genders, :female)
            end                                                         # end
          RUBY
        end

        super
      end
    end

    def update_enum_column(attr_name, key)
      value = write_enum_attribute(attr_name, key)
      column = simple_enum_attributes[attr_name.to_s].column
      update_column(column, value)
    end

    private

    def read_enum_attribute_before_conversion(attr_name)
      read_attribute(simple_enum_attributes[attr_name.to_s].column)
    end

    def write_enum_attribute_after_conversion(attr_name, value)
      write_attribute(simple_enum_attributes[attr_name.to_s].column, value)
    end
  end
end
