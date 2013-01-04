module SimpleEnum

  # The StringifiedEnum dumps the enum as String instead of the indexed number.
  #
  class StringifiedEnum

    # Allow access to values and lookup hash.
    attr_reader :lookup_hash

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

    def keys
      lookup_hash.values
    end

    def load(str)
      lookup_hash[str] if str
    end

    def dump(key)
      lookup_hash[key.to_s].try(:to_s) if key
    end

    private

    def update(ary)
      @lookup_hash = ActiveSupport::OrderedHash.new
      ary.each { |key| lookup_hash[key.to_s] = key }
    end
  end
end
