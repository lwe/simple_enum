require 'active_support/core_ext/string'
require 'active_support/hash_with_indifferent_access'

module SimpleEnum
  class Enum
    attr_reader :name, :hash, :source, :prefix

    def self.default_builder(values)
      enum_hash = ActiveSupport::HashWithIndifferentAccess.new
      pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
      pairs.each { |name, value| enum_hash[name.to_s] = value }
      enum_hash
    end

    def self.string_builder(values)
      enum_hash = ActiveSupport::HashWithIndifferentAccess.new
      values.each { |name, *args| enum_hash[name.to_s] = name.to_s }
      enum_hash
    end

    def self.build_hash(values, options)
      hash = send("#{options[:builder] || 'default'}_builder", values)
      hash.freeze
    end

    def self.source_for(name, source = nil)
      source.to_s.presence || "#{name}_cd"
    end

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
      hash.key?(key) || hash.value?(key)
    end

    def key(value)
      key = hash.key(value)
      key.to_sym if key
    end

    def value(key)
      value = hash[key]
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
