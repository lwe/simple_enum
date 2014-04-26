# SimpleEnum allows for cross-database, easy to use enum-like fields to be added to your
# ActiveRecord models. It does not rely on database specific column types like <tt>ENUM</tt> (MySQL),
# but instead on integer columns.
#
# Author:: Lukas Westermann
# Copyright:: Copyright (c) 2009 Lukas Westermann (Zurich, Switzerland)
# Licence:: MIT-Licence (http://www.opensource.org/licenses/mit-license.php)
#
# See the +as_enum+ documentation for more details.

# because we depend on i18n and activesupport
require 'i18n'
require 'active_support'

require 'simple_enum/version'
require 'simple_enum/attribute'
require 'simple_enum/translation'

# Base module which gets included in <tt>ActiveRecord::Base</tt>. See documentation
# of +SimpleEnum::ClassMethods+ for more details.
module SimpleEnum
  mattr_accessor :with
  @@with = [:query, :bang, :scope]

  mattr_accessor :accessor
  @@accessor = nil

  mattr_accessor :field
  @@field = nil
end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:extend, SimpleEnum::Attribute)
  ActiveRecord::Base.send(:extend, SimpleEnum::Translation)
end

# setup i18n load path...
I18n.load_path << File.join(File.dirname(__FILE__), '..', 'locales', 'en.yml')
