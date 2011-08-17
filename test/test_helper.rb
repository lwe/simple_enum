# Setup environment for both tests and IRB interactive console
#

$KCODE = 'u' unless RUBY_VERSION =~ /^1\.9/ # to make parameterize work...

require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'active_support'
require 'active_support/version'

# setup fake rails env
ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = 'test'


SIMPLE_ENUM_ORM = (ENV['SIMPLE_ENUM_ORM'] || :active_record).to_sym

Bundler.require(:default, SIMPLE_ENUM_ORM)

# load orm specific helpers
require File.join(ROOT, 'test', 'orm', SIMPLE_ENUM_ORM.to_s, 'init')

setup_db

# load simple_enum
require File.join(ROOT, 'init')

# load dummy class
require File.join(ROOT, 'test', 'orm', SIMPLE_ENUM_ORM.to_s, 'models')

# Test environment info
puts "Testing against: activesupport-#{ActiveSupport::VERSION::STRING}, #{SIMPLE_ENUM_ORM.to_s}-#{orm_version}"

# do some magic to initialze DB for IRB session
if Object.const_defined?('IRB')
  reload_db :fill => true, :genders => true
else # and load test classes when in test cases...
  require 'test/unit'  
  require 'active_support/test_case'
end