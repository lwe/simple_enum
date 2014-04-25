require 'simple_enum/translation'

module SimpleEnum

  # SimpleEnum::Attribute is the base class to be included in objects to get
  # the #as_enum functionality. All the including class needs to provide is
  # a setter and getter for `source`, by default the `source` is `<enum>_cd`.
  # This is similar to how relations work in Rails, the idea is not taint the
  # original method.
  #
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
        options = SimpleEnum.default_options.merge(source: "#{enum}_cd").merge(options)
        options[:prefix] = options[:prefix] && "#{options[:prefix] == true ? enum : options[:prefix]}_"
        options.assert_valid_keys(:source, :prefix, :with)

        # raise error if enum == source
        raise ArgumentError, "[simple_enum] use different names for #{enum}'s name and source name." if enum.to_s == options[:source].to_s

        self.enum_definitions[enum] = options

        enum_hash = build_enum_hash(values, options)
        singleton_class.send(:define_method, enum.to_s.pluralize) do |key = nil|
          key ? enum_hash[key] : enum_hash
        end

        generate_enum_attribute_methods_for(enum, enum_hash, options)

        options[:with].each do |feature|
          send "generate_enum_#{feature}_methods_for", enum, enum_hash, options
        end
      end

      private

      def simple_enum_module
        @simple_enum_module ||= begin
          mod = Module.new
          include mod
          mod
        end
      end

      def build_enum_hash(values, options)
        ActiveSupport::HashWithIndifferentAccess.new.tap do |enum_hash|
          pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
          pairs.each { |name, value| enum_hash[name.to_s] = value }
        end
      end

      def generate_enum_attribute_methods_for(enum, enum_hash, options)
        simple_enum_module.module_eval do
          define_method("#{enum}")  { read_enum_value(enum) }
          define_method("#{enum}=") { |value| write_enum_value(enum, value) }

          define_method("#{enum}?") do |value = nil|
            return read_enum_value(enum) unless value
            enum_hash[value] && read_enum_value_before_cast(enum) == enum_hash[value]
          end
        end
      end

      def generate_enum_dirty_methods_for(enum, enum_hash, options)
        source = options[:source]
        simple_enum_module.module_eval do
          define_method("#{enum}_changed?") { self.send("#{source}_changed?") }
          define_method("#{enum}_was") { enum_hash.key(self.send("#{source}_was")).try(:to_sym) }
        end
      end

      def generate_enum_query_methods_for(enum, enum_hash, options)
        prefix = options[:prefix]
        simple_enum_module.module_eval do
          enum_hash.each do |key, value|
            define_method("#{prefix}#{key}?") { read_enum_value_before_cast(enum) == value }
          end
        end
      end

      def generate_enum_bang_methods_for(enum, enum_hash, options)
        prefix = options[:prefix]
        simple_enum_module.module_eval do
          enum_hash.each do |key, value|
            define_method("#{prefix}#{key}!") { write_enum_value_after_cast(enum, value); key }
          end
        end
      end

      def generate_enum_scope_methods_for(enum, enum_hash, options)
        return unless respond_to?(:scope)

        source = options[:source]
        prefix = options[:prefix]

        enum_hash.each do |key, value|
          scope "#{prefix}#{key}", -> { where(source => value) }
        end
      end
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

    private

    def read_enum_value_before_cast(enum)
      source = self.class.enum_definitions[enum][:source]
      self.send source
    end

    def write_enum_value_after_cast(enum, value)
      source = self.class.enum_definitions[enum][:source]
      self.send "#{source}=", value
    end

  end
end
