require 'simple_enum/enums/enum'
require 'simple_enum/enums/multi_enum'

module SimpleEnum
  module Enums
    def self.enum(name, values, options = {})
      klass = options[:multiple] ? MultiEnum : Enum
      klass.new(name, values)
    end
  end
end
