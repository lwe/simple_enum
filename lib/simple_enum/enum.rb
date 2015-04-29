require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'

module SimpleEnum
  class Enum
    attr_reader :name

    def initialize(name, hash)
      @name = name.to_s
      @hash = hash
      @symbols_hash = hash.symbolize_keys
    end

    def include?(key)
      hash.key?(key.to_s) || hash.value?(key)
    end

    def key(value)
      key = hash.key(value)
      key.to_sym if key
    end

    def value(key)
      value = hash[key.to_s]
      value = key if hash.value?(key)
      value
    end
    alias_method :[], :value

    def each_pair(&block)
      symbols_hash.each_pair(&block)
    end
    alias_method :each, :each_pair

    def map(&block)
      symbols_hash.map(&block)
    end

    def keys
      symbols_hash.keys
    end

    def values_at(*keys)
      keys = keys.map(&:to_s)
      hash.values_at(*keys)
    end

    def to_s
      name
    end

    # Private access to hash and symbolized hash
    private
    attr_reader :hash, :symbols_hash
  end
end
