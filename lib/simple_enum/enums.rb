require 'active_support/core_ext/string'

# Load all enum coders
Dir["#{File.dirname(__FILE__)}/enums/*_enum.rb"].each do |file|
  require file
end

module SimpleEnum

  # Public: Factory method to ensure supplied values implement the enumeration
  # interface, a prefered factory type can be given.
  #
  # values - The whatever thingy should be turned into an enumeration, in most
  #          cases an Array, Hash or existing enum.
  # factory - The Symbol with the prefered enum to create.
  #
  # Returns Object which implements the enum interface, i.e. #load, #dump
  #   and #keys.
  def self.Enum(values, factory = nil)
    if [:load, :dump, :keys].all? { |m| values.respond_to?(m) }
      values
    elsif factory
      SimpleEnum.const_get("#{factory.to_s.classify}Enum").new(values)
    elsif [:each, :keys].all? { |m| values.respond_to?(m) }
      SimpleEnum::HashedEnum.new(values)
    else
      SimpleEnum::IndexedEnum.new(values)
    end
  end
end
