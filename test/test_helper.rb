# Setup environment for both tests and IRB interactive console
#

$KCODE = 'u' unless RUBY_VERSION =~ /^1\.9/ # to make parameterize work...

require 'rubygems'
require 'bundler/setup'

require 'test/unit'
require 'active_support'
require 'active_support/version'
require 'minitest/autorun'

# setup fake rails env
ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = 'test'

# load orms
ORM = ENV['ORM'] || 'active_record'

def mongoid?; return ORM == 'mongoid';end
def activerecord?; return ORM == 'active_record';end

# load database implemntation
require ORM

# load simple enum
require 'simple_enum'

# load ORM specific stuff
require 'orm/common'
require "orm/#{ORM}"

# Add test locales
I18n.load_path << File.join(File.dirname(__FILE__), 'locales.yml')

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
