require 'active_support/concern'

module SimpleEnum

  module Dirty

    extend ActiveSupport::Concern

    module ClassMethods
      def simple_enum_initialization_callback(klass, enum)
        klass.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{enum.prefix}#{enum.name}_changed?
            enum_attribute_changed?(#{enum.name.inspect})
          end

          def #{enum.prefix}#{enum.name}_was
            enum_attribute_was(#{enum.name.inspect})
          end
        RUBY

        super
      end
    end

    def enum_attribute_changed?(name)
      false
    end

    def enum_attribute_was(name)
      nil
    end
  end
end
