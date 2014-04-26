module SimpleEnum
  module Hasher
    DefaultHasher = ->(values) {
      Hash.new.tap do |enum_hash|
        pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
        pairs.each { |name, value| enum_hash[name.to_s] = value }
      end
    }

    StringHasher = ->(values) {
      Hash.new.tap do |enum_hash|
        values.each { |name, *args| enum_hash[name.to_s] = name.to_s }
      end
    }

    HASHERS = {
      string: StringHasher
    }

    def self.map(values, builder = nil)
      hasher = HASHERS[builder] || DefaultHasher
      hasher.call(values).freeze
    end
  end
end
