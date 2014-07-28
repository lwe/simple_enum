require 'i18n'

module SimpleEnum
  module ViewHelpers

    # A helper to build forms with Rails' form builder, built to be used with
    # f.select helper.
    #
    #    f.select :gender, enum_option_pairs(User, :gender), ...
    #
    # record - The model or Class with the enum
    # enum - The Symbol with the name of the enum to create the options for
    # encode_as_value - The Boolean which defines if either the key or the value
    #                   should be used as value attribute for the option,
    #                   defaults to using the key (i.e. false)
    #
    # FIXME: check if the name `enum_option_pairs` is actually good and clear
    # enough...
    #
    # Returns an Array of pairs, like e.g. `[["Translated key", "key"], ...]`
    def enum_option_pairs(record, enum, encode_as_value = false)
      reader = enum.to_s.pluralize
      record = record.class unless record.respond_to?(reader)

      record.send(reader).map { |key, value|
        name = record.human_enum_name(enum, key) if record.respond_to?(:human_enum_name)
        name ||= translate_enum_key(enum, key)
        [name, encode_as_value ? value : key]
      }
    end

    # Helper method to return the translated value of an enum.
    #
    #     translate_enum(user, :gender) # => "Frau"
    #
    # Has been aliased to `te` as a convenience method as well.
    #
    # record - The model instance holding the enum
    # key - The Symbol with the name of the enum, i.e. same key as used in the
    #       `as_enum` call
    #
    # Returns String with translation of enum
    def translate_enum(record, key)
      record.class.human_enum_name(key, record.public_send(key))
    end
    alias_method :te, :translate_enum

    private

    def translate_enum_key(enum, key)
      defaults = [:"enums.#{enum}.#{key}", key.to_s.humanize]
      I18n.translate defaults.shift, default: defaults, count: 1
    end
  end
end
