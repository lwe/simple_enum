module SimpleEnum

  # The GeneratedMethods implements the initialization callback to generate all default
  # methods like:
  #
  # - Klass.genders
  # - instance.gender
  # - instance.gender=
  # - instance.male, instance.female
  # - instance.male?, instance.female?
  #
  # It's also basically just based on the callbacks provided by SimpleEnum::Attributes. The
  # GeneratedMethods are automatically included by default and thus always available.
  module GeneratedMethods
    def simple_enum_initialization_callback(attribute)
      GeneratedMethods.generate_class_method(self.simple_enum_generated_class_methods, attribute.name, attribute.prefix)
      GeneratedMethods.generate_feature_methods(self.simple_enum_generated_feature_methods, attribute.name)
      attribute.enum.keys.each do |key|
        GeneratedMethods.generate_attribute_methods(self.simple_enum_generated_feature_methods, attribute.name, key, attribute.prefix)
      end

      super
    end

    # Creates the `Klass.genders` method to return
    def self.generate_class_method(mod, name, prefix)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{prefix}#{name.to_s.pluralize}              #   def genders
          simple_enum_attributes[#{name.inspect}].enum   #     simple_enum_attributes[:gender].enum
        end                                              #   end
      RUBY
    end

    def self.generate_feature_methods(mod, name)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}                              # def gender
          read_enum_attribute(#{name.inspect})   #   read_enum_attribute(:gender)
        end                                      # end

        def #{name}=(key)                             # def gender=(key)
          write_enum_attribute(#{name.inspect}, key)  #   write_enum_attribute(:gender, value)
        end                                           # end
      RUBY
    end

    def self.generate_attribute_methods(mod, name, key, prefix)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{prefix}#{key}                                       # def male
          write_enum_attribute(#{name.inspect}, #{key.inspect})   #   write_enum_attribute(:gender, value)
        end                                                       # end

        def #{prefix}#{key}?                                      # def male?
          read_enum_attribute(#{name.inspect}) == #{key.inspect}  #   read_enum_attribute(:gender) == :male
        end                                                       # end
      RUBY
    end
  end
end
