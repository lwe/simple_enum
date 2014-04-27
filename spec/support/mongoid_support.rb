require 'mongoid'

module MongoidSupport
  def self.connection
    @connection ||= begin
      Mongoid.configure.connect_to("simple_enum_mongoid_test")
      Mongoid.default_session.options[:max_retries] = 0
    end
    Mongoid.default_session
  end

  def self.included(base)
    base.before {
      begin
        MongoidSupport.connection.collection_names
      rescue Moped::Errors::ConnectionFailure
        pending "Start MongoDB server to run Mongoid integration tests..."
      end
    }
  end
end
