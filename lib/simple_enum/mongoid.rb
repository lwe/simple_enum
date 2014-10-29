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
      base.extend SimpleEnum::Mongoid::ClassMethods
    end

    module ClassMethods
      # Wrap method chain to create mongoid field and additional
      # column options
      def as_enum(name, values, options = {})
        source = options[:source].to_s.presence || if options[:multiple]
            "#{name.singularize}#{SimpleEnum.multi_suffix || SimpleEnum.suffix.pluralize}"
          else
            "#{name}#{SimpleEnum.suffix}"
          end
        field_options = options.delete(:field)
        unless field_options === false
          field_options ||= SimpleEnum.field
          field(source, field_options) if field_options
        end

        super
      end
    end
  end
end
