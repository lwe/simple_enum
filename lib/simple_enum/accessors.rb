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
      access = options.fetch(:accessor, SimpleEnum.accessor)
      klass = ACCESSORS[access] || Accessor
      klass.new(name, enum, options[:source], options[:prefix])
    end
  end

  # Public: Extension method to register a custom accessor.
  #
  # key - The Symbol of the accessor key, e.g. `:bitwise`
  # clazz - The Class with the accessor implementation
  #
  # Returns nothing
  def self.register_accessor(key, clazz)
    Accessors::ACCESSORS[key] = clazz
  end
end
