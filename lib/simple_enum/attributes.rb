module SimpleEnum

  module Attributes
    extend ActiveSupport::Concern

    module ClassMethods
      def generate_enum_attribute_methods_for(enum)
        define_method(enum.to_s) { read_enum_value(enum) }
        define_method("#{enum}=") { |value| write_enum_value(enum, value) }
      end
    end

    private

    def read_enum_value_before_cast(enum)
      column = self.class.enum_definitions[enum][:column]
      self.send column
    end

    def write_enum_value_before_cast(enum, value)
      column = self.class.enum_definitions[enum][:column]
      self.send "#{column}=", value
    end

    def read_enum_value(enum)
      value = read_enum_value_before_cast(enum)
      key = self.class.send("#{enum.to_s.pluralize}").key(value)
      key.try :to_sym
    end

    def write_enum_value(enum, value)
      return write_enum_value_before_cast(enum, nil) if value.blank?

      # new_value = new_value.to_s if options[:strings] FIXME: how to handle :strings option
      values = self.class.send("#{enum.to_s.pluralize}")
      real = values[value]
      real = value if values.key(value)

      write_enum_value_before_cast(enum, real)
    end
  end
end
