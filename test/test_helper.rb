# Setup environment for both tests and IRB interactive console
#
$KCODE = 'u' if RUBY_VERSION =~ /^1\.8/ # to make parameterize work...

require 'rubygems'
require 'bundler/setup'

require 'minitest/autorun'
require 'active_support'
require 'active_support/version'

# setup fake rails env
ROOT       = File.join(File.dirname(__FILE__), '..')
RAILS_ROOT = ROOT
RAILS_ENV  = 'test'

# load orms
ORM = ENV['SIMPLE_ENUM_TEST_ORM'] || 'active_record'

def mongoid?; return ORM == 'mongoid';end
def activerecord?; return ORM == 'active_record';end

# load database implemntation
require ORM

# load simple enum AFTER ORM
require 'simple_enum'

# load ORM specific stuff
require 'orm/common'
require "orm/#{ORM}"

# Add locales
I18n.load_path << File.join(File.dirname(__FILE__), 'locales.yml')

# setup db
setup_db

# Test environment info
puts "Testing against: activesupport-#{ActiveSupport::VERSION::STRING}, #{ORM.to_s}-#{orm_version}"
