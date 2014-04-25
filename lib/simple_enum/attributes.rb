module SimpleEnum

  module Attributes
    extend ActiveSupport::Concern

    module ClassMethods
      def generate_enum_attribute_methods_for(enum)
        define_method(enum.to_s) { read_enum_value(enum) }
      end
    end

    private

    def read_enum_value_before_cast(enum)
      column = self.class.enum_definitions[enum][:column]
      self.send column
    end

    def read_enum_value(enum)
      value = read_enum_value_before_cast(enum)
      key = self.class.send("#{enum.to_s.pluralize}").key(value)
      key.try :to_sym
    end
  end
end
