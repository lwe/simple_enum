module SimpleEnum
  module Accessors
    class Accessor
      attr_reader :enum

      def initialize(enum)
        @enum = enum
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
        object.attribute_changed?(source)
      end

      def was(object)
        enum.key(object.attribute_was(source))
      end

      private

      def source
        enum.source
      end

      def hash_access?
        source == enum.name
      end

      def read_before_type_cast(object)
        hash_access? ? object[source] : object.send(source)
      end

      def write_after_type_cast(object, value)
        hash_access? ? object[source] = value : object.send("#{source}=", value)
        value
      end
    end
  end
end
