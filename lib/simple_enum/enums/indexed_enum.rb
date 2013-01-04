require 'active_support/ordered_hash'

module SimpleEnum

  # The SimpleEnum::Enum provides the underlying enum definition
  # for an `as_enum` call. It holds all possible values, the options,
  # the name etc.
  #
  class IndexedEnum

    # Allow access to values and lookup hash.
    attr_reader :values, :lookup_hash

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
    def initialize(values)
      update(values.to_a)
    end

    # Keys meaning enum keys, delegate to values for array
    alias_method :keys, :values

    def load(index)
      values[index] if index
    end

    def dump(key)
      lookup_hash[key.to_s] if key
    end

    private

    def update(values)
      @values = values
      @lookup_hash = ActiveSupport::OrderedHash.new
      values.each_with_index { |key, idx|
        @lookup_hash[key.to_s] = idx
      }
    end
  end
end
