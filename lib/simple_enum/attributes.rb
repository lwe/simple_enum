module SimpleEnum

  module Attributes
    extend ActiveSupport::Concern

    module ClassMethods
      def generate_enum_attribute_methods_for(enum, values, options)
        column = options[:column]

        define_method("#{enum}")  { read_enum_value(enum) }
        define_method("#{enum}=") { |value| write_enum_value(enum, value) }

        define_method("#{enum}?") do |value = nil|
          return read_enum_value(enum) unless value
          read_enum_value(enum) == value
        end

        unless options[:slim]
          values.each do |key, value|
            define_method("#{options[:prefix]}#{key}?") { read_enum_value_before_cast(enum) == value }
            define_method("#{options[:prefix]}#{key}!") { write_enum_value_after_cast(enum, value); key }
          end
        end

        if options[:dirty]
          define_method("#{enum}_changed?") { self.send("#{column}_changed?") }
          define_method("#{enum}_was") { values.key(self.send("#{column}_was")).try(:to_sym) }
        end
      end
    end

    private

    def read_enum_value_before_cast(enum)
      column = self.class.enum_definitions[enum][:column]
      self.send column
    end

    def write_enum_value_after_cast(enum, value)
      column = self.class.enum_definitions[enum][:column]
      self.send "#{column}=", value
    end

    def read_enum_value(enum)
      value = read_enum_value_before_cast(enum)
      key = self.class.send("#{enum.to_s.pluralize}").key(value)
      key.try :to_sym
    end

    def write_enum_value(enum, value)
      return write_enum_value_after_cast(enum, nil) if value.blank?

      # new_value = new_value.to_s if options[:strings] FIXME: how to handle :strings option
      values = self.class.send("#{enum.to_s.pluralize}")
      real = values[value]
      real = value if values.key(value)

      write_enum_value_after_cast(enum, real)
    end
  end
end
