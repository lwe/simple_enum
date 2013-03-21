require 'active_support/core_ext/string'

module SimpleEnum

  #
  #
  module ClassMethods

    # Public:
    def simple_enum_initialization_callback(type)
      name = type.name.to_s.pluralize
      mod = simple_enum_generated_class_methods

      mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{name}
          simple_enum_attributes[#{type.name.inspect}].model
        end
      RUBY

      super
    end
  end
end
