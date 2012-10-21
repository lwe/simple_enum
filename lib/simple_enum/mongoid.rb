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
  #   field :gender_cd, :type => Integer
  #   as_enum :gender, [:female, :male], :field => false
  #
  # or custom field options (like e.g. type want to be passed):
  #
  #   as_enum :gender, [:female, :male], :field => { :type => Integer }
  #
  module Mongoid
    extend ActiveSupport::Concern

    included do
      # create class level methods
      class_attribute :simple_enum_definitions, :instance_writer => false, :instance_reader => false
    end

    module ClassMethods
      include SimpleEnum::ClassMethods

      # Wrap method chain to create mongoid field and additional
      # column options
      def as_enum_with_mongoid(enum_cd, values, options = {})
        options = SimpleEnum.default_options.merge({ :column => "#{enum_cd}_cd" }).deep_merge(options)

        # forward custom field options
        field_options = options.delete(:field)
        field(options[:column], field_options.is_a?(Hash) ? field_options : {}) unless field_options === false

        # call original as_enum method
        as_enum_without_mongoid(enum_cd, values, options)
      end
      alias_method_chain :as_enum, :mongoid
    end
  end
end
