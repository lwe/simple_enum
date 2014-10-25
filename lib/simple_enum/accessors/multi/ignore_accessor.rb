require 'simple_enum/accessors/multi/accessor'

module SimpleEnum
  module Accessors
    module Multi
      class IgnoreAccessor < Accessor
        def write(object, key)
          super if to_values_array(key)
        end
      end
    end
  end
end
