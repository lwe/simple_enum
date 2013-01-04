require 'active_record'
require 'active_support/concern'

require 'simple_enum/attributes'
require 'simple_enum/persistence'
require 'simple_enum/dirty'

# Extend ActiveRecord::Base
ActiveRecord::Base.module_eval do
  include SimpleEnum::Attributes
  include SimpleEnum::Persistence
  extend  SimpleEnum::Dirty
end
