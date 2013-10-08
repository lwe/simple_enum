require 'active_support/core_ext/string'

module SimpleEnum
  module Scopes

    def simple_enum_initialization_callback(type)
      if type.options[:scopes]
        type.model.lookup_hash.each do |attr, value|
          simple_enum_generated_class_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attr.pluralize}                  # def males
              where(:#{type.column} => #{value})   #  where(:gender_cd => 0)
            end                                    # end
          RUBY
        end
      end

      super
    end

  end
end
