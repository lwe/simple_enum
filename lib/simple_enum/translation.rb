require 'i18n'

module SimpleEnum
  module Translation
    def human_enum_name(enum, key, options = {})
      return '' unless key.present?

      defaults = lookup_ancestors.map do |klass|
        :"#{self.i18n_scope}.enums.#{klass.model_name.i18n_key}.#{enum}.#{key}"
      end

      defaults << :"enums.#{self.model_name.i18n_key}.#{enum}.#{key}"
      defaults << :"enums.#{enum}.#{key}"
      defaults << options.delete(:default) if options[:default]
      defaults << key.to_s.humanize

      options.reverse_merge! count: 1, default: defaults
      I18n.translate(defaults.shift, options)
    end
  end
end
