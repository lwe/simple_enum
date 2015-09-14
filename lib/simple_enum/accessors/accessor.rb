module SimpleEnum
  module Accessors
    class Accessor
      attr_reader :name, :enum, :source

      def initialize(name, enum, source = nil, prefix = nil)
        @name = name.to_s
        @enum = enum
        @source = source.to_s.presence || "#{name}#{SimpleEnum.suffix}"
        @prefix = prefix
      end

      def prefix
        @cached_prefix ||= @prefix && "#{@prefix == true ? name : @prefix}_" || ""
      end

      def read(object)
        enum.key(read_before_type_cast(object))
      end

      def write(object, key)
        write_after_type_cast(object, enum[key]) && key
      end

      def selected?(object, key = nil)
        current = read_before_type_cast(object)
        return current && current == enum[key] if key
        current
      end

      def changed?(object)
        object.send(:attribute_changed?, source)
      end

      def was(object)
        changes = object.send(:changed_attributes)
        key = changes.fetch(source, read_before_type_cast(object))
        enum.key(key) if key
      end

      def scope(relation, value)
        relation.where(source => value)
      end

      def to_s
        name
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
end
