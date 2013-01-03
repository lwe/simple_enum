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

    # Creates the `Klass.genders` method to return
    def simple_enum_class_initialization_callback(mod, enum)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{enum.prefix}#{enum.name.to_s.pluralize}    #   def genders
          simple_enum_attributes[#{enum.name.inspect}]   #     simple_enum_attributes[:gender]
        end                                              #   end
      RUBY

      super
    end

    def simple_enum_feature_initialization_callback(mod, enum)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{enum.name}                              # def gender
          read_enum_attribute(#{enum.name.inspect})   #   read_enum_attribute(:gender)
        end                                           # end

        def #{enum.name}=(key)                             # def gender=(key)
          write_enum_attribute(#{enum.name.inspect}, key)  #   write_enum_attribute(:gender, value)
        end                                                # end
      RUBY

      super
    end

    def simple_enum_attribute_initialization_callback(mod, enum, key)
      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{enum.prefix}#{key}                                       # def male
          write_enum_attribute(#{enum.name.inspect}, #{key.inspect})   #   write_enum_attribute(:gender, value)
        end                                                            # end

        def #{enum.prefix}#{key}?                                      # def male?
          read_enum_attribute(#{enum.name.inspect}) == #{key.inspect}  #   read_enum_attribute(:gender) == :male
        end                                                            # end
      RUBY

      super
    end
  end
end
