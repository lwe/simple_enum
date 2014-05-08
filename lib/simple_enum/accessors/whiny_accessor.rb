require 'simple_enum/accessors/accessor'

module SimpleEnum
  module Accessors
    class WhinyAccessor < Accessor
      def write(object, key)
        raise ArgumentError, "#{key} is not a valid enum value for #{enum}" if key && !enum.include?(key)
        super
      end
    end
  end
end
