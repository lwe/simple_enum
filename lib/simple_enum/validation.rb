module SimpleEnum
  module Validation
    
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
    # * <tt>:on</tt> - Specifies when this validation is active (default is <tt>:save</tt>, other options <tt>:create</tt>, <tt>:update</tt>).
    # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
    #   occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The
    #   method, proc or string should return or evaluate to a true or false value.
    # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
    #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The
    #   method, proc or string should return or evaluate to a true or false value.
    def validates_as_enum(*attr_names)
      @configuration = { :on => :save }
      @configuration.update(attr_names.extract_options!)      
      attr_names.map! { |e| enum_definitions[e][:column] } # map to column name
      validates_each(attr_names) do |record, attr_name, value|
        enum_def = enum_definitions[attr_name]
        unless send(enum_def[:name].to_s.pluralize).values.include?(value)
          record.errors.add(enum_def[:name], :invalid_enum, :default => @configuration[:message], :value => value)
        end
      end
    end
  end
end