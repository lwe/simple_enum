require 'simple_enum/accessors/multi/accessor'

module SimpleEnum
  module Accessors
    module Multi
      class WhinyAccessor < Accessor
        def write(object, key)
          raise ArgumentError, "#{key} is not a valid enum value for #{enum}" if valid_array?(key)
          super
        end
        private
        def valid_array?(key)
          key && (!to_keys_array(key) && !to_values_array(key))
        end
      end
    end
  end
end
