require 'mongoid'

# Hack to disable auto-retries for Mongo::Client - unless running
# on Travis CI
if ENV['CI'] && Mongoid.respond_to?(:default_client)
  require 'mongo'

  module Mongo
    class Cluster
      def scan!
        raise ArgumentError, 'no retries please.'
      end
    end
  end
end

module MongoidSupport
  def self.connection
    @connection_config ||= begin
      Mongoid.configure do |config|
        config.connect_to("simple_enum_mongoid_test", max_retries: ENV['CI'] ? 5 : 0)
      end

      # Disable client errors
      Moped.logger.level = Logger::ERROR if defined?(Moped)
      Mongo::Logger.logger.level = Logger::ERROR if defined?(Mongo)

      # Return instance
      return Mongoid.default_client if Mongoid.respond_to?(:default_client)
      Mongoid.default_session
    end
  end

  def self.included(base)
    base.before {
      begin
        MongoidSupport.connection.database_names
      rescue => e
        if ENV['CI']
          raise e
        else
          skip "Start MongoDB server to run Mongoid integration tests..."
        end
      end
    }
  end
end
