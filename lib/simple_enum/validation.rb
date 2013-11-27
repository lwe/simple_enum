module ActiveModel
  module Validations
    class AsEnumValidator < ActiveModel::Validator
      attr_reader :attributes

      def initialize(options)
        @attributes = Array.wrap(options.delete(:attributes))
        raise ":attributes cannot be blank" if @attributes.empty?
        super
      end

      def setup(klass)
        @klass = klass
      end

      def validate(record)
        attributes.each do |attribute|
          enum_def = @klass.enum_definitions[attribute]
          raw_value = record.send(enum_def[:column])

          raw_value = raw_value.to_s if enum_def[:options][:strings] && raw_value

          next if (raw_value.nil? && options[:allow_nil]) || (raw_value.blank? && options[:allow_blank])

          unless @klass.send(enum_def[:name].to_s.pluralize).values.include?(raw_value)
            record.errors.add(attribute, :invalid_enum, options)
          end
        end
      end
    end

    module HelperMethods
      # Validates an +as_enum+ field based on the value of it's column.
      #
      # Model:
      #    class User < ActiveRecord::Base
      #      as_enum :gender, [ :male, :female ]
      #      validates_as_enum :gender
      #    end
      #
      # View:
      #    <%= select(:user, :gender, User.genders.keys) %>
      #
      # Configuration options:
      # * <tt>:message</tt> - A custom error message (default: is <tt>[:activerecord, :errors, :messages, :invalid_enum]</tt>).
      # * <tt>:on</tt> - Specifies when this validation is active (default is always, other options <tt>:create</tt>, <tt>:update</tt>).
      # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
      #   occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The
      #   method, proc or string should return or evaluate to a true or false value.
      # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
      #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The
      #   method, proc or string should return or evaluate to a true or false value.
      def validates_as_enum(*attr_names)
        validates_with AsEnumValidator, _merge_attributes(attr_names)
      end
    end
  end
end
