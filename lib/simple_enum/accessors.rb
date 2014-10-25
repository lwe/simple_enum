require 'simple_enum/accessors/accessor'
require 'simple_enum/accessors/ignore_accessor'
require 'simple_enum/accessors/whiny_accessor'
require 'simple_enum/accessors/multi/accessor'
require 'simple_enum/accessors/multi/ignore_accessor'
require 'simple_enum/accessors/multi/whiny_accessor'

module SimpleEnum
  module Accessors
    ACCESSORS = {
      default: Accessor,
      ignore: IgnoreAccessor,
      whiny:  WhinyAccessor,
      multi_default: Multi::Accessor,
      multi_ignore: Multi::IgnoreAccessor,
      multi_whiny:  Multi::WhinyAccessor,
    }

    def self.accessor(name, enum, options = {})
      multi = options.fetch(:multi, SimpleEnum.multi)
      access = options.fetch(:accessor, SimpleEnum.accessor)
      access_key = multi ? "multi_#{access}".to_sym : access
      klass = ACCESSORS[access_key] || Accessor
      klass.new(name, enum, options[:source], options[:prefix])
    end
  end
end
