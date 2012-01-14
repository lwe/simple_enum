require 'simple_enum'

module SimpleEnum
  
  # Enables support for mongoid, also automatically creates the
  # requested field.
  #
  #   class Person
  #     include Mongoid::Document
  #     include SimpleEnum::Mongoid
  #
  #     field :name
  #     as_enum :gender, [:female, :male]
  #   end
  #
  # When no field is requested:
  #
  #   field :gender_cd, :type => String
  #   as_enum :gender, [:female, :male], :field => false
  #
  # or custom field options (like e.g. type want to be passed):
  #
  #   as_enum :gender, [:female, :male], :field => { :type => Fixnum }
  # 
  module Mongoid
    extend ActiveSupport::Concern
    
    included do
      # create class level methods
      class_attribute :enum_definitions, :instance_write => false, :instance_reader => false
      enum_definitions = {}
    end
    
    module ClassMethods
      include SimpleEnum::ClassMethods
      
      # Wrap method chain to create mongoid field and additional
      # column options
      def as_enum_with_mongoid(enum_cd, values, options = {})
        options = SimpleEnum.default_options.merge({ :column => "#{enum_cd}_cd" }).merge(options)
        field = options.delete(:field)
        field options[:column]
        
        # call original as_enum method
        as_enum_without_mongoid(enum_cd, values, options)
      end
      alias_method_chain :as_enum, :mongoid
    end
  end
end