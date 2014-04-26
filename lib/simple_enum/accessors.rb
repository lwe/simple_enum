require 'simple_enum/accessors/accessor'
require 'simple_enum/accessors/ignore_accessor'
require 'simple_enum/accessors/whiny_accessor'

module SimpleEnum
  module Accessors
    ACCESSORS = {
      :ignore => IgnoreAccessor,
      :whiny => WhinyAccessor
    }

    def self.accessor(enum, options = {})
      klass = ACCESSORS[options[:accessor]] || Accessor
      klass.new(enum)
    end
  end
end
