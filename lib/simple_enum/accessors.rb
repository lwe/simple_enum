require 'simple_enum/accessors/accessor'
require 'simple_enum/accessors/ignore_accessor'
require 'simple_enum/accessors/whiny_accessor'

module SimpleEnum
  module Accessors
    ACCESSORS = {
      ignore: IgnoreAccessor,
      whiny:  WhinyAccessor
    }

    def self.accessor(name, enum, options = {})
      access = options[:accessor] || SimpleEnum.accessor
      klass = ACCESSORS[access] || Accessor
      klass.new(name, enum, options[:source], options[:prefix], options[:multiple])
    end
  end
end
