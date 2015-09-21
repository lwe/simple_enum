require 'active_support/core_ext/array'

require 'simple_enum/enum'
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
    # Registered registrator methods from extensions
    EXTENSIONS = []

    def as_enum(name, values, options = {})
      options.assert_valid_keys(:source, :prefix, :with, :accessor, :map)

      hash     = SimpleEnum::Hasher.map(values, options)
      enum     = SimpleEnum::Enum.new(name, hash)
      accessor = SimpleEnum::Accessors.accessor(name, enum, options)

      generate_enum_class_accessors_for(enum, accessor)
      generate_enum_instance_accessors_for(enum, accessor)

      Array.wrap(options.fetch(:with, SimpleEnum.with)).each do |feature|
        send "generate_enum_#{feature}_methods_for", enum, accessor
      end

      EXTENSIONS.uniq.each do |extension|
        send "generate_enum_#{extension}_extension_for", enum, accessor
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
        scope "#{accessor.prefix}#{key.pluralize}", -> { accessor.scope(self, value) }
      end
    end
  end

  # Public: Register a generator method and add module as part of
  # SimpleEnum::Attribute. The generator method is called after all default
  # generators have been created, this allows to override/change existing methods.
  #
  # name - The Symbol with the name of the extension
  # mod - The Module implementing `generate_enum_{name}_extension_for` method
  #
  # Returns nothing
  def self.register_generator(name, mod)
    Attribute.send :include, mod
    Attribute::EXTENSIONS << name.to_s
  end
end
