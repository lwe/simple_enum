require 'active_support/hash_with_indifferent_access'

module SimpleEnum
  class Enum
    attr_reader :name, :hash, :source, :prefix

    def initialize(name, hash, source = nil, prefix = nil)
      @name = name.to_s
      @hash = ActiveSupport::HashWithIndifferentAccess.new(hash)
      @source = source.to_s.presence || "#{name}_cd"
      @prefix = prefix
    end

    def [](key)
      hash[key]
    end

    def prefix
      @cached_prefix ||= @prefix && "#{@prefix == true ? name : @prefix}_" || ""
    end

    def read(object)
      key = hash.key(read_before_type_cast(object))
      key.try :to_sym
    end

    def write(object, key)
      value = hash[key]
      value = key if hash.key(key)
      write_after_type_cast(object, value) && key
    end

    def selected?(object, key = nil)
      current = read_before_type_cast(object)
      return current && current == hash[key] if key
      current
    end

    def changed?(object)
      object.attribute_changed?(source)
    end

    def was(object)
      key = hash.key(object.attribute_was(source))
      key.try(:to_sym)
    end

    private

    def read_before_type_cast(object)
      source == name ? object[source] : object.send(source)
    end

    def write_after_type_cast(object, value)
      source == name ? object[source] = value : object.send("#{source}=", value)
      value
    end
  end
end
