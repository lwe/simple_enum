require 'rubygems'
require 'bundler/setup'

require 'rspec'
require 'active_support'
require 'active_record'

require 'simple_enum'

require 'support/active_record_support'
require 'support/i18n_support'
require 'support/model_support'

I18n.enforce_available_locales = false

RSpec.configure do |config|
  config.include ModelSupport
  config.include I18nSupport, i18n: true
  config.include ActiveRecordSupport, active_record: true
end
