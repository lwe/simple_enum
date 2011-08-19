# Setup environment for both tests and IRB interactive console
#

$KCODE = 'u' unless RUBY_VERSION =~ /^1\.9/ # to make parameterize work...

require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'active_support'
require 'active_support/version'
require 'active_record'
require 'mongoid'
require 'minitest/autorun'

# setup fake rails env
ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = 'test'

# load simple enum
require 'simple_enum'

# load orms
ORM = ENV['ORM'] || 'activerecord'

def mongoid?; return ORM == 'mongoid';end
def activerecord?; return ORM == 'activerecord';end

require 'orm/common'
require "orm/#{ORM}"

# setup db
setup_db

# Test environment info
puts "Testing against: activesupport-#{ActiveSupport::VERSION::STRING}, #{ORM.to_s}-#{orm_version}"

# do some magic to initialze DB for IRB session
if Object.const_defined?('IRB')
  reload_db :fill => true, :genders => true
else # and load test classes when in test cases...
  require 'test/unit'  
  require 'active_support/test_case'
end