require 'simple_enum'
require 'mongoid'

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
    def self.included(base)
      base.extend SimpleEnum::ClassMethods
      base.class_eval do
        class_attribute :simple_enum_definitions, instance_writer: false,
                                                  instance_reader: false
      end
      base.prepend AsEnumRedefinition
    end

    module AsEnumRedefinition
      module ClassMethods
        # Wrap method chain to create mongoid field and additional
        # column options
        def as_enum(enum_cd, values, options = {})
          options = SimpleEnum.default_options.merge(column: "#{enum_cd}_cd").deep_merge(options)

          # forward custom field options
          field_options = options.delete(:field)
          field(options[:column], field_options.is_a?(Hash) ? field_options : {}) unless field_options === false

          # call original as_enum method
          super(enum_cd, values, options)
        end
      end

      def self.prepended(base)
        class << base
          prepend ClassMethods
        end
      end
    end
  end
end
