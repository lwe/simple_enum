require 'active_support/ordered_hash'
require 'active_support/deprecation'
require 'active_support/core_ext/module'

module SimpleEnum

  # The SimpleEnum::Enum provides the underlying enum definition
  # for an `as_enum` call. It holds all possible values, the options,
  # the name etc.
  #
  class Enum

    # Name and options are directly accessible
    attr_reader :name, :options

    # Public: Creates a new enum instance using a name,
    # a hash or array of values and options.
    #
    # name - The Symbol or String with the name of the enum,
    #        is converted to a symbol, always.
    # values - The Hash or Array of enum values.
    # options - The Hash with additional options, like the
    #           :prefix.
    #
    # Returns new enum definition instance.
    def initialize(name, values, options = {})
      @name = name.to_sym
      @options = options
      replace(values)
    end

    delegate :keys, :values, :to => :@lookup_hash

    # Public: Convenience method to access `options[:prefix]`.
    #
    # Returns String with prefix, or `nil`, affixed with `_`.
    def prefix
      @prefix ||= options[:prefix] && "#{options[:prefix] == true ? name : options[:prefix]}_"
    end

    def [](key)
      @lookup_hash[key.to_sym]
    end

    def key(value)
      @reverse_hash[value.to_s]
    end

    def replace(values)
      @lookup_hash = ActiveSupport::OrderedHash.new
      @reverse_hash = Hash.new
      values.each_with_index { |obj, idx|
        @lookup_hash[obj.to_sym] = idx
        @reverse_hash[idx.to_s] = obj.to_sym
      }
    end
  end
end
