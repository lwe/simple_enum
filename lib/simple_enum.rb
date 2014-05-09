# SimpleEnum allows for cross-database, easy to use enum-like fields to be added to your
# ActiveRecord models. It does not rely on database specific column types like <tt>ENUM</tt> (MySQL),
# but instead on integer columns.
#
# Author:: Lukas Westermann
# Copyright:: Copyright (c) 2009-2014 Lukas Westermann (Zurich, Switzerland)
# License:: MIT-Licence (http://www.opensource.org/licenses/mit-license.php)
#
# See the +as_enum+ documentation for more details.

require 'active_support'

require 'simple_enum/version'
require 'simple_enum/attribute'
require 'simple_enum/translation'
require 'simple_enum/view_helpers'

# Base module which gets included in <tt>ActiveRecord::Base</tt>. See documentation
# of +SimpleEnum::ClassMethods+ for more details.
module SimpleEnum
  mattr_accessor :with
  @@with = [:attribute, :dirty, :scope]

  mattr_accessor :accessor
  @@accessor = :default

  mattr_accessor :builder
  @@builder = :default

  mattr_accessor :suffix
  @@suffix = "_cd"

  mattr_accessor :field
  @@field = {}

  def self.configure
    yield(self)
  end
end

# Load rails support
require 'simple_enum/railtie' if defined?(Rails)
