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

    def self.map(values, options = {})
      mapper = options.fetch(:map, SimpleEnum.builder)
      mapper = HASHERS[mapper] || DefaultHasher unless mapper.respond_to?(:call)
      mapper.call(values).freeze
    end
  end
end
