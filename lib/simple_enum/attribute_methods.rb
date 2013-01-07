require 'active_support/concern'

module SimpleEnum

  # The AttributeMethods implements the initialization callback to generate the default
  # attribute methods like:
  #
  # - instance.gender
  # - instance.gender=
  # - instance.male, instance.female
  # - instance.male?, instance.female?
  #
  # These module is automatically included by default.
  module AttributeMethods
    extend ActiveSupport::Concern

    # Internal: Generate the setter and getter methods.
    #
    # Returns nothing.
    def self.generate_readwrite_methods(mod, name)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}                                   # def gender
          read_enum_attribute(#{name.inspect})        #   read_enum_attribute('gender')
        end                                           # end

        def #{name}=(key)                             # def gender=(key)
          write_enum_attribute(#{name.inspect}, key)  #   write_enum_attribute('gender', key)
        end                                           # end
      RUBY
    end

    # Internal: Generate the non-bang method to write the attribute and the
    # question mark thingy.
    #
    # Returns nothing.
    def self.generate_attribute_methods(mod, name, key, prefix)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{prefix}#{key}                                       # def female
          write_enum_attribute(#{name.inspect}, #{key.inspect})   #   write_enum_attribute('gender', :female)
        end                                                       # end

        def #{prefix}#{key}?                                         # def female?
          enum_attribute_selected?(#{name.inspect}, #{key.inspect})  #   enum_attribute_selected?('gender', :female)
        end                                                          # end
      RUBY
    end

    module ClassMethods

      # Internal: The callback after `as_enum` generates the reader/writer and the
      # attribute methods for each available key.
      #
      # Must call super.
      #
      # Returns nothing.
      def simple_enum_initialization_callback(type)
        mod = self.simple_enum_generated_feature_methods

        AttributeMethods.generate_readwrite_methods(mod, type.name)
        type.keys.each do |key|
          AttributeMethods.generate_attribute_methods(mod, type.name, key, type.prefix)
        end

        super
      end
    end

    # Public: Reads the stored value for an enumeration and converts
    # it to the enumerated value. Integrations for ActiveRecord or
    # Mongoid should override `read_enum_attribute_before_conversion`
    # instead.
    #
    # attr_name - The String (or Symbol) with the attribute to read.
    #
    # Returns stored value, normally a Number
    def read_enum_attribute(attr_name)
      value = read_enum_attribute_before_conversion(attr_name)
      simple_enum_attributes[attr_name.to_s].load(value)
    end

    # Public: Write attribute value for enum, converts the key to
    # the enum value and delegates to `write_enum_attribute_after_conversion`
    # which integrations like AR/Mongoid can override
    #
    # attr_name - The String (or Symbol) with the attribute to write.
    # key - The Symbol or String with the value to write.
    #
    # Returns stored and converted value.
    def write_enum_attribute(attr_name, key)
      value = simple_enum_attributes[attr_name.to_s].dump(key)
      write_enum_attribute_after_conversion(attr_name, value)
      value
    end

    # Public: Test if the supplied key is selected in the enum
    # attribute.
    #
    # attr_name - The String (or Symbol) with the enum attribute name to
    #             test against.
    # key - The Symbol or String with the key to test the enum attribute for.
    #
    # Returns Boolean, `true` if the supplied key matches the current enum
    # attribute.
    def enum_attribute_selected?(attr_name, key)
      value = simple_enum_attributes[attr_name.to_s].dump(key)
      read_enum_attribute_before_conversion(attr_name) == value
    end

    private

    # Public: Reads the plain attribute before conversion from
    # an instance variable.
    #
    # Returns enumeration before
    def read_enum_attribute_before_conversion(attr_name)
      instance_variable_get(:"@#{attr_name}")
    end

    # Public: Writes the converted value as instance variable.
    def write_enum_attribute_after_conversion(attr_name, value)
      instance_variable_set("@#{attr_name}", value)
    end
  end
end
