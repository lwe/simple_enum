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
  # It's also basically just based on the `simple_enum_initialization_callback`. The
  # GeneratedMethods are automatically included by default and thus always available.
  module GeneratedMethods

    #
    #
    def simple_enum_initialization_callback(klass, enum)
      GeneratedMethods.generate_class_method_for(klass, enum)
      GeneratedMethods.generate_getter(klass, enum)
      GeneratedMethods.generate_setter(klass, enum)
      enum.keys.each { |key| GeneratedMethods.generate_attribute_methods(klass, enum, key) }

      super
    end

    def self.generate_class_method_for(klass, enum)
      klass.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        module ClassMethods                                # module ClassMethods
          def #{enum.prefix}#{enum.name.to_s.pluralize}    #   def genders
            simple_enum_attributes[#{enum.name.inspect}]   #     simple_enum_attributes[:gender]
          end                                              #   end
        end                                                # end
      RUBY
    end

    def self.generate_getter(klass, enum)
      klass.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{enum.name}                                                   # def gender
          value = read_enum_attribute(#{enum.name.inspect})                #   value = read_enum_attribute(:gender)
          self.class.#{enum.prefix}#{enum.name.to_s.pluralize}.key(value)  #   self.class.genders.key(value)
        end                                                                # end
      RUBY
    end

    def self.generate_setter(klass, enum)
      klass.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{enum.name}=(key)                                              # def gender=(key)
          value = self.class.#{enum.prefix}#{enum.name.to_s.pluralize}[key] #   value = self.class.genders[key]
          write_enum_attribute(#{enum.name.inspect}, value)                 #   write_enum_attribute(:gender, value)
        end                                                                 # end
      RUBY
    end

    def self.generate_attribute_methods(klass, enum, key)
      klass.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{enum.prefix}#{key}                                                        # def male
          value = self.class.#{enum.prefix}#{enum.name.to_s.pluralize}[#{key.inspect}]  #   value = self.calss.genders[:male]
          write_enum_attribute(#{enum.name.inspect}, value)                             #   write_enum_attribute(:gender, value)
        end                                                                             # end

        def #{enum.prefix}#{key}?                                                       # def male?
          value = self.class.#{enum.prefix}#{enum.name.to_s.pluralize}[#{key}.inspect]  #   value = self.class.genders[:male]
          read_enum_attribute(#{enum.name.inspect}) == #{key.inspect}                   #   read_enum_attribute(:gender) == value
        end                                                                             # end
      RUBY
    end
  end
end
