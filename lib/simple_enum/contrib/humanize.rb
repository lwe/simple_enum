require 'active_support/concern'

module SimpleEnum
  module Contrib
    module Humanize

      # Hook which generates gender_to_human which delegates to human_enum_name
      # to translate the current attribute value.
      #
      # Returns nothing.
      def simple_enum_initialization_callback(type)
        simple_enum_generated_feature_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{type.name}_to_human                                           # def gender_to_human
            value = read_enum_attribute(#{type.name.inspect})                 #   value = read_enum_attribute('gender')
            self.class.human_enum_name(#{type.name.inspect}, value) if value  #   self.class.human_enum_name('gender', value) if value
          end                                                                 # end
        RUBY

        super
      end
    end
  end
end
