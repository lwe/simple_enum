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

require 'simple_enum/attribute'

# Base module which gets included in <tt>ActiveRecord::Base</tt>. See documentation
# of +SimpleEnum::ClassMethods+ for more details.
module SimpleEnum
  # Provides configurability to SimpleEnum, allows to override some defaults which are
  # defined for all uses of +as_enum+. Most options from +as_enum+ are available, such as:
  # * <tt>:prefix</tt> - Define a prefix, which is prefixed to the shortcut methods (e.g. <tt><symbol>!</tt> and
  #   <tt><symbol>?</tt>), if it's set to <tt>true</tt> the enumeration name is used as a prefix, else a custom
  #   prefix (symbol or string) (default is <tt>nil</tt> => no prefix)
  # * <tt>:slim</tt> - If set to <tt>true</tt> no shortcut methods for all enumeration values are being generated, if
  #   set to <tt>:class</tt> only class-level shortcut methods are disabled (default is <tt>nil</tt> => they are generated)
  # * <tt>:upcase</tt> - If set to +true+ the <tt>Klass.foos</tt> is named <tt>Klass.FOOS</tt>, why? To better suite some
  #   coding-styles (default is +false+ => downcase)
  # * <tt>:whiny</tt> - Boolean value which if set to <tt>true</tt> will throw an <tt>ArgumentError</tt>
  #   if an invalid value is passed to the setter (e.g. a value for which no enumeration exists). if set to
  #   <tt>false</tt> no exception is thrown and the internal value is set to <tt>nil</tt> (default is <tt>true</tt>)
  # * <tt>:dirty</tt> - Boolean value which if set to <tt>true</tt> generates <tt>..._was</tt> and <tt>..._changed?</tt>
  #   methods for the enum, which delegate to the internal column.
  # * <tt>:strings</tt> - Boolean value which if set to <tt>true</tt> defaults array values as strings instead of integers.
  mattr_accessor :default_options
  @@default_options = {
    with: [:query, :bang, :scope]
  }
end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, SimpleEnum::Attribute)
  ActiveRecord::Base.send(:extend, SimpleEnum::Translation)
end

# setup i18n load path...
I18n.load_path << File.join(File.dirname(__FILE__), '..', 'locales', 'en.yml')
