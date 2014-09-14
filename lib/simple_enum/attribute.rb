require 'active_support/core_ext/array'

require 'simple_enum/enums'
require 'simple_enum/hasher'
require 'simple_enum/accessors'

module SimpleEnum

  # SimpleEnum::Attribute is the base class to be included in objects to get
  # the #as_enum functionality. All the including class needs to provide is
  # a setter and getter for `source`, by default the `source` is `<enum>_cd`.
  # This is similar to how relations work in Rails, the idea is not taint the
  # original method.
  #
  module Attribute
    def as_enum(name, values, options = {})
      options.assert_valid_keys(:source, :prefix, :with, :accessor, :map, :multiple)

      hash     = SimpleEnum::Hasher.map(values, options)
      enum     = SimpleEnum::Enums.enum(name, hash, options)
      accessor = SimpleEnum::Accessors.accessor(name, enum, options)

      generate_enum_class_accessors_for(enum, accessor)
      generate_enum_instance_accessors_for(enum, accessor)

      Array.wrap(options.fetch(:with, SimpleEnum.with)).each do |feature|
        send("generate_enum_#{feature}_methods_for", enum, accessor)
      end

      enum
    end

    private

    def simple_enum_module
      @simple_enum_module ||= Module.new.tap { |mod| include mod }
    end

    def generate_enum_class_accessors_for(enum, accessor)
      name = accessor.name.pluralize
      singleton_class.send(:define_method, name) { enum }
      singleton_class.send(:define_method, "#{name}_accessor") { accessor }
    end

    def generate_enum_instance_accessors_for(enum, accessor)
      simple_enum_module.module_eval do
        define_method("#{accessor}")  { accessor.read(self) }
        define_method("#{accessor}=") { |value| accessor.write(self, value) }
        define_method("#{accessor}?") { |value = nil| accessor.selected?(self, value) }
      end
    end

    def generate_enum_dirty_methods_for(enum, accessor)
      simple_enum_module.module_eval do
        define_method("#{accessor}_changed?") { accessor.changed?(self) }
        define_method("#{accessor}_was")      { accessor.was(self) }
      end
    end

    def generate_enum_attribute_methods_for(enum, accessor)
      simple_enum_module.module_eval do
        enum.each_pair do |key, value|
          define_method("#{accessor.prefix}#{key}?") { accessor.selected?(self, key) }
          define_method("#{accessor.prefix}#{key}!") { accessor.write(self, key) }
        end
      end
    end

    def generate_enum_scope_methods_for(enum, accessor)
      return unless respond_to?(:scope)

      enum.each_pair do |key, value|
        scope "#{accessor.prefix}#{key.pluralize}", -> { where(accessor.source => value) }
      end
    end
  end
end
