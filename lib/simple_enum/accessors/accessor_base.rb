module SimpleEnum
  module Accessors
    class AccessorBase
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
        raise 'You should implement "read" method in your accessor class.'
      end

      def write(object, key)
        raise 'You should implement "write" method in your accessor class.'
      end

      def selected?(object, key = nil)
        raise 'You should implement "selected?" method in your accessor class.'
      end

      def changed?(object)
        object.send(:attribute_changed?, source)
      end

      def was(object)
        raise 'You should implement "was" method in your accessor class.'
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
