require 'simple_enum/accessors/accessor_base'

module SimpleEnum
  module Accessors
    module Multi
      class Accessor < AccessorBase
        def read(object)
          values = read_before_type_cast(object)
          to_keys_array(values)
        end

        def write(object, key)
          write_after_type_cast(object, to_values_array(key)) && key
        end

        def selected?(object, key = nil)
          values = read_before_type_cast(object)
          ori_keys = to_keys_array(values)
          if ori_keys && key
            if given_keys = to_keys_array(to_values_array(key))
              return (given_keys.reject { |gk| !ori_keys.include?(gk) } == given_keys)
            else
              return nil
            end
          end
          ori_keys
        end

        def was(object)
          values = object.send(:attribute_was, source)
          to_keys_array(values)
        end

        private

        def to_keys_array(values)
          if values.is_a?(Array)
            keys = values.sort.map { |v| enum.key(v) }
          else
            keys = [enum.key(values)]
          end
          keys.include?(nil) ? nil : keys
        end

        def to_values_array(keys)
          if keys.is_a?(Array)
            values = keys.map { |k| enum[k] }
          else
            values = [enum[keys]]
          end
          values.include?(nil) ? nil : values.sort
        end
      end
    end
  end
end
