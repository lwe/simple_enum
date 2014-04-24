require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'active_support'
require 'active_record'

require 'simple_enum'

require 'support/database_support'
require 'support/dummy'

RSpec.configure do |config|
  config.before do
    DatabaseSupport.create_dummies
  end
end
