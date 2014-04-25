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

require 'simple_enum/enum_hash'
require 'simple_enum/attributes'
require 'simple_enum/validation'
require 'simple_enum/translation'

require 'active_support/deprecation'

# Base module which gets included in <tt>ActiveRecord::Base</tt>. See documentation
# of +SimpleEnum::ClassMethods+ for more details.
module SimpleEnum
  extend ActiveSupport::Concern

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
    whiny: true,
    upcase: false,
    scopes: true
  }

  included do
    class_attribute :enum_definitions, instance_write: false, instance_reader: false
    self.enum_definitions = {}

    include SimpleEnum::Attributes
    extend SimpleEnum::Translation
  end

  def inherited(base)
    base.enum_definitions = enum_definitions.deep_dup
    super
  end

  module ClassMethods

    # Provides ability to create simple enumerations based on hashes or arrays, backed
    # by integer columns (but not limited to integer columns).
    #
    # Columns are supposed to be suffixed by <tt>_cd</tt>, if not, use <tt>:column => 'the_column_name'</tt>,
    # so some example migrations:
    #
    #   add_column :users, :gender_cd, :integer
    #   add_column :users, :status, :integer # and a custom column...
    #
    # and then in your model:
    #
    #   class User < ActiveRecord::Base
    #     as_enum :gender, [:male, :female]
    #   end
    #
    #   # or use a hash:
    #
    #   class User < ActiveRecord::Base
    #     as_enum :user_status, { :active => 1, :inactive => 0, :archived => 2, :deleted => 3 }, :column => 'status'
    #   end
    #
    # Now it's possible to access the enumeration and the internally stored value like:
    #
    #   john_doe = User.new
    #   john_doe.gender          # => nil
    #   john_doe.gender = :male
    #   john_doe.gender          # => :male
    #   john_doe.gender_cd       # => 0
    #
    # And to make life a tad easier: a few shortcut methods to work with the enumeration are also created.
    #
    #   john_doe.male?           # => true
    #   john_doe.female?         # => false
    #   john_doe.female!         # => :female (set's gender to :female => gender_cd = 1)
    #   john_doe.male?           # => false
    #
    # Sometimes it's required to access the db-backed values, like e.g. in a query:
    #
    #   User.genders             # =>  { :male => 0, :female => 1}, values hash
    #   User.genders(:male)      # => 0, value access (via hash)
    #   User.female              # => 1, direct access
    #   User.find :all, :conditions => { :gender_cd => User.female }  # => [...], list with all women
    #
    # To access the key/value assocations in a helper like the select helper or similar use:
    #
    #   <%= select(:user, :gender, User.genders.keys)
    #
    # The generated shortcut methods (like <tt>male?</tt> or <tt>female!</tt> etc.) can also be prefixed
    # using the <tt>:prefix</tt> option. If the value is <tt>true</tt>, the shortcut methods are prefixed
    # with the name of the enumeration.
    #
    #   class User < ActiveRecord::Base
    #     as_enum :gender, [:male, :female], :prefix => true
    #   end
    #
    #   jane_doe = User.new
    #   jane_doe.gender = :female   # this is still as-is
    #   jane_doe.gender_cd          # => 1, and so it this
    #
    #   jane_doe.gender_female?     # => true (instead of jane_doe.female?)
    #
    # It is also possible to supply a custom prefix.
    #
    #   class Item < ActiveRecord::Base
    #     as_enum :status, [:inactive, :active, :deleted], :prefix => :state
    #   end
    #
    #   item = Item.new(:status => :active)
    #   item.state_inactive?       # => false
    #   Item.state_deleted         # => 2
    #   Item.status(:deleted)      # => 2, same as above...
    #
    # To disable the generation of the shortcut methods for all enumeration values, add <tt>:slim => true</tt> to
    # the options.
    #
    #   class Address < ActiveRecord::Base
    #     as_enum :canton, {:aargau => 'ag', ..., :wallis => 'vs', :zug => 'zg', :zurich => 'zh'}, :slim => true
    #   end
    #
    #   home = Address.new(:canton => :zurich, :street => 'Bahnhofstrasse 1', ...)
    #   home.canton       # => :zurich
    #   home.canton_cd    # => 'zh'
    #   home.aargau!      # throws NoMethodError: undefined method `aargau!'
    #   Address.aargau    # throws NoMethodError: undefined method `aargau`
    #
    # This is especially useful if there are (too) many enumeration values, or these shortcut methods
    # are not required.
    #
    # If you would like ActiveRecord scopes for each value, add <tt>:scopes => true</tt> to the options.
    #
    # class User < ActiveRecord::Base
    #   as_enum :gender, [:male, :female], :scopes => true
    # end
    #
    # women = User.female  # => ActiveRecord::Relation for Users where gender is female
    # men = User.male      # => ActiveRecord::Relation for Users where gender is male
    #
    # === Configuration options:
    # * <tt>:column</tt> - Specifies a custom column name, instead of the default suffixed <tt>_cd</tt> column
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
    #   methods for the enum, which delegate to the internal column (default is <tt>false</tt>)
    # * <tt>:strings</tt> - Boolean value which if set to <tt>true</tt> stores array values as strings instead of it's index.
    # * <tt>:field</tt> - Also allowed as valid key, for Mongoid integration + default options, see simple_enum#27.
    # * <tt>:scopes</tt> - Boolean value which if set to <tt>true</tt> will define ActiveRecord scopes for each value.
    #
    def as_enum(enum, values, options = {})
      options = SimpleEnum.default_options.merge(column: "#{enum}_cd").merge(options)
      options[:prefix] = options[:prefix] && "#{options[:prefix] == true ? enum : options[:prefix]}_"
      options.assert_valid_keys(:column, :whiny, :prefix, :slim, :upcase, :dirty, :strings, :field, :scopes)

      # convert array to hash
      enum_hash = ActiveSupport::HashWithIndifferentAccess.new
      singleton_class.send(:define_method, enum.to_s.pluralize) do |key = nil|
        key ? enum_hash[key] : enum_hash
      end

      # Handle prefix

      pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
      pairs.each do |name, value|
        enum_hash[name] = value

        if options.fetch(:scopes, true) && respond_to?(:scope)
          scope name, -> { where(options[:column] => value) }
        end
      end

      # store info away
      self.enum_definitions[enum] = options

      # raise error if enum == column
      raise ArgumentError, "[simple_enum] use different names for #{enum}'s name and column name." if enum.to_s == options[:column].to_s

      generate_enum_attribute_methods_for(enum, enum_hash, options)

      # allow access to defined values hash, e.g. in a select helper or finder method.
      attr_name = enum.to_s.pluralize
      enum_attr = :"#{attr_name.downcase}_enum_hash"

      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        def self.#{attr_name}_for_select(attr = :key, &block)
          self.#{attr_name}.map do |k,v|
            [block_given? ? yield(k,v) : self.human_enum_name(#{attr_name.inspect}, k), attr == :value ? v : k]
          end
        end
      RUBY
    end
  end
end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, SimpleEnum)
end

# setup i18n load path...
I18n.load_path << File.join(File.dirname(__FILE__), '..', 'locales', 'en.yml')
