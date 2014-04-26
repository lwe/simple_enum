require 'simple_enum/accessors/accessor'

module SimpleEnum
  module Accessors
    class IgnoreAccessor < Accessor
      def write(object, key)
        super if !key || enum.include?(key)
      end
    end
  end
end
