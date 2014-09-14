require 'active_support/core_ext/string'

module SimpleEnum
  autoload :Enum, 'simple_enum/enum'

  module Enums
    class Enum
      attr_reader :name, :hash

      def initialize(name, hash)
        @name = name.to_s
        @hash = hash
      end

      def include?(key)
        hash.key?(key.to_s) || hash.value?(key)
      end

      def match?(key, current)
        value(key) == current
      end

      def key(value)
        key = hash.key(value)
        key.to_sym if key
      end

      def value(key)
        hash.value?(key) ? key : hash[key.to_s]
      end
      alias_method :[], :value

      def each_pair(&block)
        hash.each_pair(&block)
      end
      alias_method :each, :each_pair

      def map(&block)
        hash.map(&block)
      end

      def keys
        hash.keys
      end

      def values_at(*keys)
        keys = keys.map(&:to_s)
        hash.values_at(*keys)
      end

      def to_s
        name
      end
    end
  end
end
