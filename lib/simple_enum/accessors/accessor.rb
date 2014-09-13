module SimpleEnum
  module Accessors
    class Accessor
      attr_reader :name, :enum, :source, :prefix

      def initialize(name, enum, source = nil, prefix = nil, multiple = false)
        @name = name.to_s
        @enum = enum
        @source = source.to_s.presence || if multiple
            "#{name.to_s.singularize}"\
            "#{SimpleEnum.multi_suffix || SimpleEnum.suffix.pluralize}"
          else
            "#{name}#{SimpleEnum.suffix}"
          end
        @prefix = prefix ? "#{prefix == true ? name : prefix}_" : ""
      end

      def read(object)
        enum.key(read_before_type_cast(object))
      end

      def write(object, key)
        write_after_type_cast(object, enum.value(key)) && key
      end

      def selected?(object, key = nil)
        current = read_before_type_cast(object)
        return current && enum.match?(key, current) if key
        current.present?
      end

      def changed?(object)
        object.send(:attribute_changed?, source)
      end

      def was(object)
        enum.key(object.send(:attribute_was, source))
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
