require 'active_support/deprecation'
require 'active_support/core_ext/module'

module SimpleEnum

  # The EnumType represents an enumeration attribute, with it's name,
  # the model (load/dump/keys) and the provided options.
  class EnumType

    # Allow access to name, model and options
    attr_reader :name, :model, :options

    # Public: Create a new enumeration type instance.
    #
    # name - The Symbol or String with the attribute name to
    #        created, is converted to a string.
    # model - The Object which responds to #load, #dump and #keys
    #         and represents the real enumeration (values/keys).
    # options - The Hash with additional options passed.
    #
    # Returns a new instance.
    def initialize(name, model, options = {})
      @name = name.to_s
      @model = model
      @options = options
    end

    # Simplified access to #load, #dump and #keys on model.
    delegate :dump, :load, :keys, :to => :model

    # Returns String with prefix for methods, if any.
    def prefix
      @prefix ||= options[:prefix] && "#{options[:prefix] == true ? name : options[:prefix]}_"
    end

    # Returns String with column name, or `options[:column]`.
    def column
      @column ||= options[:column] || "#{name}_cd"
    end
  end
end
