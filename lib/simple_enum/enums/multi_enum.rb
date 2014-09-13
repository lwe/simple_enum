require 'simple_enum/enums/enum'

module SimpleEnum
  module Enums
    class MultiEnum < Enum

      def include?(keys)
        Array.wrap(keys).all? do |key|
          super key
        end
      end

      def match?(keys, current)
        return false unless include? keys
        current = Array.wrap(current)
        value(keys).all? do |value|
          current.include? value
        end
      end

      def key(values)
        Array.wrap(values).map do |value|
          super value
        end.compact
      end

      def value(keys)
        Array.wrap(keys).map do |key|
          super key
        end.compact
      end
      alias_method :[], :value

    end
  end
end