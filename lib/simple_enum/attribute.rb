require 'simple_enum/translation'
require 'simple_enum/enum'

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
      extend SimpleEnum::Translation
    end

    module ClassMethods
      def as_enum(name, values, options = {})
        options = SimpleEnum.default_options.merge(options)
        options.assert_valid_keys(:source, :prefix, :with)

        enum = build_simple_enum(name, values, options)

        generate_enum_class_methods_for(enum)
        generate_enum_attribute_methods_for(enum)

        options[:with].each do |feature|
          send "generate_enum_#{feature}_methods_for", enum
        end
      end

      private

      def build_simple_enum(name, values, options)
        hash = ActiveSupport::HashWithIndifferentAccess.new.tap do |enum_hash|
          pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
          pairs.each { |name, value| enum_hash[name.to_s] = value }
        end

        SimpleEnum::Enum.new name, hash.freeze, options[:source], options[:prefix]
      end

      def simple_enum_module
        @simple_enum_module ||= begin
          mod = Module.new
          include mod
          mod
        end
      end

      def generate_enum_class_methods_for(enum)
        singleton_class.send(:define_method, enum.name.pluralize) { enum }
      end

      def generate_enum_attribute_methods_for(enum)
        simple_enum_module.module_eval do
          define_method("#{enum.name}")  { enum.read(self) }
          define_method("#{enum.name}=") { |value| enum.write(self, value) }
          define_method("#{enum.name}?") { |value = nil| enum.selected?(self, value) }
        end
      end

      def generate_enum_dirty_methods_for(enum)
        simple_enum_module.module_eval do
          define_method("#{enum.name}_changed?") { enum.changed?(self) }
          define_method("#{enum.name}_was") { enum.was(self) }
        end
      end

      def generate_enum_query_methods_for(enum)
        simple_enum_module.module_eval do
          enum.hash.each do |key, value|
            define_method("#{enum.prefix}#{key}?") { enum.selected?(self, key) }
          end
        end
      end

      def generate_enum_bang_methods_for(enum)
        simple_enum_module.module_eval do
          enum.hash.each do |key, value|
            define_method("#{enum.prefix}#{key}!") { enum.write(self, key) }
          end
        end
      end

      def generate_enum_scope_methods_for(enum)
        return unless respond_to?(:scope)

        enum.hash.each do |key, value|
          scope "#{enum.prefix}#{key}", -> { where(enum.source => value) }
        end
      end
    end
  end
end
