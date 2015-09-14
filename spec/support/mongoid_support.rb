require 'mongoid'

module MongoidSupport
  def self.connection
    @connection ||= begin
      Mongoid.configure.connect_to("simple_enum_mongoid_test")
    end
    Mongoid.default_client
  end

  def self.included(base)
    base.before {
      begin
        MongoidSupport.connection.list_databases
      rescue
        skip "Start MongoDB server to run Mongoid integration tests..."
      end
    }
  end
end
