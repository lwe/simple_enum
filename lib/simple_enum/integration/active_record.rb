require 'active_record'
require 'active_support/concern'

require 'simple_enum/dirty'
require 'simple_enum/persistence'

# Extend ActiveRecord::Base
ActiveRecord::Base.module_eval do
  include SimpleEnum::Attributes
  include SimpleEnum::Persistence
  extend  SimpleEnum::Dirty
end
