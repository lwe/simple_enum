require 'active_support/core_ext/string'
require 'active_support/hash_with_indifferent_access'

module SimpleEnum
  class Enum
    attr_reader :name, :hash, :source, :prefix

    def self.enum(name, values, options)
      enum_hash = {}
      pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
      pairs.each { |name, value| enum_hash[name.to_s] = value }

      self.new name, enum_hash.freeze, options[:source], options[:prefix]
    end

    def self.source_for(name, source = nil)
      source.to_s.presence || "#{name}_cd"
    end

    def initialize(name, hash, source = nil, prefix = nil)
      @name = name.to_s
      @hash = ActiveSupport::HashWithIndifferentAccess.new(hash).freeze
      @source = self.class.source_for(name, source)
      @prefix = prefix
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

    def to_s
      name
    end
  end
end
