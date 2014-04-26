require 'active_support/core_ext/string'

module SimpleEnum
  class Enum
    def self.build_hash(values, options)
      method = options[:builder] || SimpleEnum.builder || 'default'
      hash = send("#{method}_hash_builder", values)
      hash.freeze
    end

    def self.default_hash_builder(values)
      enum_hash = {}
      pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
      pairs.each { |name, value| enum_hash[name.to_s] = value }
      enum_hash
    end

    def self.string_hash_builder(values)
      enum_hash = {}
      values.each { |name, *args| enum_hash[name.to_s] = name.to_s }
      enum_hash
    end

    def self.source_for(name, source = nil)
      source.to_s.presence || "#{name}_cd"
    end

    attr_reader :name, :hash, :source, :prefix

    def initialize(name, values, options = {})
      @name = name.to_s
      @hash = self.class.build_hash(values, options)
      @source = self.class.source_for(name, options[:source])
      @prefix = options[:prefix]
    end

    def prefix
      @cached_prefix ||= @prefix && "#{@prefix == true ? name : @prefix}_" || ""
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
      hash.each_pair(&block)
    end

    def to_s
      name
    end
  end
end
