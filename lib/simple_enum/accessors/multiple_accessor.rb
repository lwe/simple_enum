require 'simple_enum/accessors/accessor'
require 'simple_enum/collection_proxy'

module SimpleEnum
  module Accessors
    class MultipleAccessor < Accessor
      def source
        @cached_source ||= @source.to_s.presence || 
          "#{name.singularize}#{SimpleEnum.multi_suffix || SimpleEnum.suffix.pluralize}"
      end

      def read(object)
        CollectionProxy.new(read_before_type_cast(object), self)
      end

      def write(object, keys)
        keys = filter_keys(Array.wrap(keys))
        write_after_type_cast(object, fetch_values(keys)) && keys
      end

      def selected?(object, key = nil)
        current = read_before_type_cast(object)
        current.any? && if key 
            current.all? do 
              current.include?(enum.value(key))
            end
          else
            true
          end
      end

      def was(object)
        fetch_keys(object.send(:attribute_was, source).to_a)
      end

      def scope(collection, key, value)
        raise "scopes for accessor: :multiple are not supported!"
      end

      def filter_keys(keys)
        keys.select do |key|
          enum.value(key)
        end
      end

      def fetch_keys(values)
        values.map do |value| 
          enum.key(value)
        end
      end

      def fetch_values(keys)
        keys.map do |key| 
          enum.value(key)
        end
      end

      private

      def read_before_type_cast(object)
        result = super
        unless result
          result = []
          write_after_type_cast(object, result)
        end
        result 
      end
    end
  end
end