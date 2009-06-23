module SimpleEnum
  module Version #:nodoc:
    MAJOR = 0
    MINOR = 5
    TINY = 0
    
    STRING = [MAJOR, MINOR, TINY].join('.').freeze
    
    def self.to_s; STRING; end
  end
  
  NAME = "simple_enum".freeze
  ABOUT = "#{NAME} #{Version}".freeze
end