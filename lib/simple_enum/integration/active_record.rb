require 'active_record'
require 'active_support/concern'

module SimpleEnum
  module Integration

    # Public: Provide integration for active record, allows
    # to use dirty and bang methods, whooop whoop.
    module ActiveRecord
      extend ActiveSupport::Concern

      module ClassMethods
        #
        def simple_enum_initialization_callback(klass, enum)
          column = enum.options[:column] ||= "#{enum.name}_cd".to_sym
          ActiveRecord.generate_dirty_methods klass, enum, column
          enum.keys.each { |key| ActiveRecord.generate_bang_methods(klass, enum, column, key) }

          super
        end
      end

      def self.generate_dirty_methods(klass, enum, column)
        klass.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{enum.name}_changed?                                          # def gender_changed?
            #{column}_changed?                                               #   gender_cd_changed?
          end                                                                # end

          def #{enum.name}_was                                               # def gender_was
            value = #{column}_was                                            #   value = gender_cd_was
            self.class.#{enum.prefix}#{enum.name.to_s.pluralize}.key(value)  #   self.class.genders.key(value)
          end                                                                # end
        RUBY
      end

      def self.generate_bang_methods(klass, enum, column, key)
        klass.module_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{enum.prefix}#{key}!                                                       # def male!
            value = self.class.#{enum.prefix}#{enum.name.to_s.pluralize}[#{key.inspect}]  #   value = self.calss.genders[:male]
            update_attribute(#{column.inspect}, value)                                    #   update_attribute(:gender_cd, value)
          end                                                                             # end
        RUBY
      end

      def read_enum_attribute(attribute)
        self[simple_enum_column_name(attribute)]
      end

      def write_enum_attribute(attribute, value)
        self[simple_enum_column_name(attribute)] = value
      end

      private

      def simple_enum_column_name(attribute)
        self.class.simple_enum_attributes[attribute].options[:column]
      end
    end
  end
end

# Extend ActiveRecord::Base
ActiveRecord::Base.send(:include, SimpleEnum::Attributes)
ActiveRecord::Base.send(:include, SimpleEnum::Integration::ActiveRecord)
