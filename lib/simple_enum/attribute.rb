require 'simple_enum/translation'

module SimpleEnum

  module Attribute
    extend ActiveSupport::Concern

    included do
      class_attribute :enum_definitions, instance_write: false, instance_reader: false
      self.enum_definitions = {}

      extend SimpleEnum::Translation
    end

    def inherited(base)
      base.enum_definitions = enum_definitions.deep_dup
      super
    end

    module ClassMethods
      def as_enum(enum, values, options = {})
        options = SimpleEnum.default_options.merge(column: "#{enum}_cd").merge(options)
        options.assert_valid_keys(:column, :whiny, :prefix, :slim, :upcase, :dirty, :strings, :field, :scopes)

        # raise error if enum == column
        raise ArgumentError, "[simple_enum] use different names for #{enum}'s name and column name." if enum.to_s == options[:column].to_s

        # convert array to hash
        enum_hash = ActiveSupport::HashWithIndifferentAccess.new
        singleton_class.send(:define_method, enum.to_s.pluralize) do |key = nil|
          key ? enum_hash[key] : enum_hash
        end

        # Handle prefix
        prefix = options[:prefix] && "#{options[:prefix] == true ? enum : options[:prefix]}_"

        pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
        pairs.each do |name, value|
          enum_hash[name.to_s] = value

          generate_enum_prefixed_value_methods_for(enum, prefix, name, value) unless options[:slim]
          generate_enum_scopes_for(enum, prefix, name, value, options) if options.fetch(:scopes, true)
        end

        # store info away
        self.enum_definitions[enum] = options

        generate_enum_attribute_methods_for(enum, enum_hash, options)
        generate_enum_dirty_methods_for(enum, enum_hash, options) if options[:dirty]
      end

      private

      def generate_enum_attribute_methods_for(enum, values, options)
        column = options[:column]

        define_method("#{enum}")  { read_enum_value(enum) }
        define_method("#{enum}=") { |value| write_enum_value(enum, value) }

        define_method("#{enum}?") do |value = nil|
          return read_enum_value(enum) unless value
          values[value] && read_enum_value_before_cast(enum) == values[value]
        end
      end

      def generate_enum_dirty_methods_for(enum, values, options)
        column = options[:column]
        define_method("#{enum}_changed?") { self.send("#{column}_changed?") }
        define_method("#{enum}_was") { values.key(self.send("#{column}_was")).try(:to_sym) }
      end

      def generate_enum_prefixed_value_methods_for(enum, prefix, key, value)
        define_method("#{prefix}#{key}?") { read_enum_value_before_cast(enum) == value }
        define_method("#{prefix}#{key}!") { write_enum_value_after_cast(enum, value); key }
      end

      def generate_enum_scopes_for(enum, prefix, key, value, options)
        column = options[:column]
        scope "#{prefix}#{key}", -> { where(column => value) } if respond_to?(:scope)
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
