module SimpleEnum
  module VERSION #:nodoc:
    def self.version
      @VERSION_PARTS ||= YAML.load_file File.join(File.dirname(__FILE__), '..', '..', 'VERSION.yml')
    end
    
    def self.to_s
      @VERSION ||= [version[:major], version[:minor], version[:patch]].join('.').freeze
    end
  end
  
  NAME = "simple_enum".freeze
  ABOUT = "#{NAME} #{VERSION}".freeze
end