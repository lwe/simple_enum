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
  #   field :gender_cd, type: Integer
  #   as_enum :gender, [:female, :male], field: false
  #
  # or custom field options (like e.g. type want to be passed):
  #
  #   as_enum :gender, [:female, :male], field: { type: Integer }
  #
  module Mongoid
    def self.included(base)
      base.extend SimpleEnum::Attribute
      base.extend SimpleEnum::Translation
    end

    module Extension
      # Wrap method chain to create mongoid field and additional
      # column options
      def generate_enum_mongoid_extension_for(enum, accessor, options)
        field_options = options.delete(:field)
        return if field_options === false
        field_options ||= SimpleEnum.field
        field(accessor.source, field_options) if field_options
      end
    end
  end
end

SimpleEnum::Attribute::VALID_OPTION_KEYS.push :field
SimpleEnum.register_generator :mongoid, SimpleEnum::Mongoid::Extension
