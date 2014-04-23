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
require 'simple_enum/validation'

require 'active_support/deprecation'

# Base module which gets included in <tt>ActiveRecord::Base</tt>. See documentation
# of +SimpleEnum::ClassMethods+ for more details.
module SimpleEnum

  class << self

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
    def default_options
      @default_options ||= {
        :whiny => true,
        :upcase => false
      }
    end

    def included(base) #:nodoc:
      base.send :class_attribute, :simple_enum_definitions, :instance_writer => false, :instance_reader => false
      base.send :extend, ClassMethods
    end
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
    #
    def as_enum(enum_cd, values, options = {})
      options = SimpleEnum.default_options.merge({ :column => "#{enum_cd}_cd" }).merge(options)
      options.assert_valid_keys(:column, :whiny, :prefix, :slim, :upcase, :dirty, :strings, :field)

      metaclass = (class << self; self; end)

      # convert array to hash
      values = SimpleEnum::EnumHash.new(values, options[:strings])
      values_inverted = values.invert

      # store info away
      self.enum_definitions[enum_cd] = self.enum_definitions[options[:column]] = { :name => enum_cd, :column => options[:column], :options => options }

      # raise error if enum_cd == column
      raise ArgumentError, "[simple_enum] use different names for #{enum_cd}'s name and column name." if enum_cd.to_s == options[:column].to_s

      # generate getter
      define_method("#{enum_cd}") do
        id = send(options[:column])
        values_inverted[id]
      end

      # generate setter
      define_method("#{enum_cd}=") do |new_value|
        return send("#{options[:column]}=", nil) if new_value.blank?

        new_value = new_value.to_s if options[:strings]
        real = nil
        if values.contains?(new_value)
          real = values[EnumHash.symbolize(new_value)]
          real = new_value if real.nil? && values_inverted[new_value].present?
        end

        raise ArgumentError, "Invalid enumeration value: #{new_value}" if options[:whiny] && !real
        send("#{options[:column]}=", real)
      end

      # generate checker
      define_method("#{enum_cd}?") do |*args|
        current = send(enum_cd)
        return current.to_s == args.first.to_s if args.length > 0

        !!current
      end

      # support dirty attributes by delegating to column, currently opt-in
      if options[:dirty]
        define_method("#{enum_cd}_changed?") do
          self.send("#{options[:column]}_changed?")
        end

        define_method("#{enum_cd}_was") do
          values_inverted[self.send("#{options[:column]}_was")]
        end
      end

      # allow access to defined values hash, e.g. in a select helper or finder method.
      attr_name = enum_cd.to_s.pluralize
      enum_attr = :"#{attr_name.downcase}_enum_hash"

      define_method("human_#{enum_cd}") do
        self.class.human_enum_name(attr_name, self.send(enum_cd)) unless self.send(enum_cd).nil?
      end

      # generate find_by enum singleton
      (class << self; self end).send(:define_method, "find_by_#{enum_cd}") do |*args|
        send("find_by_#{options[:column]}", args)
      end

      class_eval(<<-RUBY, __FILE__, __LINE__ + 1)
        class_attribute #{enum_attr.inspect}, :instance_writer => false, :instance_reader => false

        def self.#{attr_name}(*args)
          return #{enum_attr} if args.first.nil?
          return #{enum_attr}[args.first] if args.size == 1
          args.inject([]) { |ary, sym| ary << #{enum_attr}[sym]; ary }
        end

        def self.#{attr_name}_for_select(attr = :key, &block)
          self.#{attr_name}.map do |k,v|
            [block_given? ? yield(k,v) : self.human_enum_name(#{attr_name.inspect}, k), attr == :value ? v : k]
          end
        end
      RUBY

      # write values
      self.send "#{enum_attr}=", values

      # only create if :slim is not defined
      if options[:slim] != true
        # create both, boolean operations and *bang* operations for each
        # enum "value"
        prefix = options[:prefix] && "#{options[:prefix] == true ? enum_cd : options[:prefix]}_"

        values.each do |k,code|
          sym = EnumHash.symbolize(k)

          define_method("#{prefix}#{sym}?") do
            current = send(options[:column])
            code == current
          end
          define_method("#{prefix}#{sym}!") do
            send("#{options[:column]}=", code)
            sym
          end

          # allow class access to each value
          unless options[:slim] === :class
            metaclass.send(:define_method, "#{prefix}#{sym}", Proc.new { |*args| args.first ? k : code })
          end
        end
      end
    end

    def human_enum_name(enum, key, options = {})
      defaults = lookup_ancestors.map do |klass|
        :"#{self.i18n_scope}.enums.#{klass.model_name.i18n_key}.#{enum}.#{key}"
      end

      defaults << :"enums.#{self.model_name.i18n_key}.#{enum}.#{key}"
      defaults << :"enums.#{enum}.#{key}"
      defaults << options.delete(:default) if options[:default]
      defaults << key.to_s.humanize

      options.reverse_merge! :count => 1, :default => defaults
      I18n.translate(defaults.shift, options)
    end

    def enum_definitions
      self.simple_enum_definitions ||= {}
    end
  end
end

# include in AR
ActiveSupport.on_load(:active_record) do
  ActiveRecord::Base.send(:include, SimpleEnum)
end

# setup i18n load path...
I18n.load_path << File.join(File.dirname(__FILE__), '..', 'locales', 'en.yml')
