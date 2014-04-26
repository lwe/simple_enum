module SimpleEnum
  module Hasher
    module DefaultHasher
      def self.hash(values)
        HASH.new.tap do |enum_hash|
          pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
          pairs.each { |name, value| enum_hash[name.to_s] = value }
        end
      end
    end

    module StringHasher
      def self.hash(values)
        HASH.new.tap do |enum_hash|
          values.each { |name, *args| enum_hash[name.to_s] = name.to_s }
        end
      end
    end

    HASH = ::Hash

    HASHERS = {
      string: StringHasher
    }

    def self.hash(values, options = {})
      hasher = HASHERS[options[:builder] || SimpleEnum.builder] || DefaultHasher
      hasher.hash(values).freeze
    end
  end
end
