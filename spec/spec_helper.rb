require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'active_support'
require 'active_record'

require 'simple_enum'

require 'support/database_support'
require 'support/i18n_support'

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.include I18nSupport, i18n: true

  config.before do
    DatabaseSupport.create_dummies
  end
end
