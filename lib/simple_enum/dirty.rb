module SimpleEnum

  # The SimpleEnum::Dirty module provides a initialization hook to
  # ties into `ActiveModel::Dirty`. It expects `attribute_changed?`
  # and `attribute_was` methods to be available.
  #
  # It implements:
  #
  # - instance.gender_changed?
  # - instance.gender_was
  #
  module Dirty

    # Hook which generates gender_was and gender_changed? methods which delegate
    # to `ActiveModel::Dirty` attribute methods, then calls super.
    #
    # Returns nothing.
    def simple_enum_initialization_callback(type)
      simple_enum_generated_feature_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{type.name}_changed?                          # def gender_changed?
          attribute_changed?(#{type.column.to_s.inspect})  #   attribute_changed?('gender_cd')
        end                                                # end

        def #{type.name}_was                                        # def gender_was
          value = attribute_was(#{type.column.to_s.inspect})        #   value = attribute_was('gender_cd')
          simple_enum_attributes[#{type.name.inspect}].load(value)  #   simple_enum_attributes['gender'].load(value)
        end                                                         # end
      RUBY

      super
    end
  end
end
