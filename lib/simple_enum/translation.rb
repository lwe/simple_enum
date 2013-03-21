require 'i18n'
require 'active_support/core_ext/string'

module SimpleEnum

  # Provides integration with `ActiveModel::Translation` to lookup
  # enumeration attribute names.
  #
  # A minimal implementation could be:
  #
  #    class Message
  #       include SimpleEnum::Attributes
  #       extend SimpleEnum::Translation
  #
  #       as_enum :priority, [:low, :medium, :high]
  #    end
  #    Message.human_enum_name :priority, :low
  #
  # Depends on AM::Translation's `i18n_scope` and `lookup_ancestor`.
  module Translation

    # Transforms enum name into human format, such as "High" instead of :high,
    # uses same lookup method as `human_attribute_name`.
    #
    # attribute - The String with the name of the enum attribute, used as namespace,
    #             is pluralized.
    # enum - The String with enum key used for lookup within attribute.
    # options - The Hash with additional options passed to `I18n.translate`.
    #
    # Returns String with enum in human format.
    def human_enum_name(attribute, enum, options = {})
      defaults = []
      namespace = attribute.to_s.pluralize

      lookup_ancestors.each do |klass|
        defaults << :"#{self.i18n_scope}.enums.#{klass.model_name.i18n_key}.#{namespace}.#{enum}"
        defaults << :"#{self.i18n_scope}.enums.#{klass.model_name.i18n_key}.#{enum}"
      end

      defaults << :"enums.#{namespace}.#{enum}"
      defaults << :"enums.#{enum}"
      defaults << options.delete(:default) if options[:default]
      defaults << enum.to_s.humanize

      options.reverse_merge! :count => 1, :default => defaults
      I18n.translate defaults.shift, options
    end
  end
end
