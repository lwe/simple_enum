require 'simple_enum/enums/enum'

module SimpleEnum
  class Enum < SimpleEnum::Enums::Enum
    puts "SimpleEnum::Enum is deprecated and will be removed from SimpleEnum, "\
      "please use SimpleEnum::Enums::Enum instead."
  end
end