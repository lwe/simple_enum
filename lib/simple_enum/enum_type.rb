require 'active_support/deprecation'
require 'active_support/core_ext/module'

module SimpleEnum
  class EnumType
    attr_reader :name, :model, :options

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
