require 'active_support/ordered_hash'

module SimpleEnum
  class HashedEnum
    attr_reader :lookup_hash, :reverse_hash

    def initialize(hash)
      update(hash)
    end

    def keys
      reverse_hash.values
    end

    def load(value)
      reverse_hash[value.to_s]
    end

    def dump(key)
      lookup_hash[key.to_s]
    end

    private

    def update(hash)
      @lookup_hash = ActiveSupport::OrderedHash.new
      @reverse_hash = Hash.new
      hash.each { |key, value|
        @lookup_hash[key.to_s] = value
        @reverse_hash[value.to_s] = key
      }
    end
  end
end
