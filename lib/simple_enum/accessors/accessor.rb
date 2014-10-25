require 'simple_enum/accessors/accessor_base'

module SimpleEnum
  module Accessors
    class Accessor < AccessorBase
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

      def was(object)
        enum.key(object.send(:attribute_was, source))
      end
    end
  end
end
