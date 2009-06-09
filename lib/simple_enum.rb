# SimpleEnum allows for cross-database, easy to use enum-like fields to be added to your
# ActiveRecord models. It does not rely on database specific column types like <tt>ENUM</tt> (MySQL),
# but instead on integer columns.
#
# Author:: Lukas Westermann
# Copyright:: Copyright (c) 2009 Lukas Westermann (Zurich, Switzerland)
# Licence:: MIT-Licence (http://www.opensource.org/licenses/mit-license.php)
#
# See the +as_enum+ documentation for more details.
module SimpleEnum
  
  # Current simple_enum version string
  VERSION = '0.2.0'
  
  def self.included(base) #:nodoc:
    base.send :extend, ClassMethods
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
    #     as_enum :status, { :active => 1, :inactive => 0, :archived => 2, :deleted => 3 }, :column => 'status'
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
    #
    # This is especially useful if there are (too) many enumeration values, or these shortcut methods
    # are not required.
    #
    # === Configuration options:
    # * <tt>:column</tt> - Specifies a custom column name, instead of the default suffixed <tt>_cd</tt> column
    # * <tt>:prefix</tt> - Define a prefix, which is prefixed to the shortcut methods (e.g. <tt><symbol>!</tt> and
    #   <tt><symbol>?</tt>), if it's set to <tt>true</tt> the enumeration name is used as a prefix, else a custom
    #   prefix (symbol or string) (default is <tt>nil</tt> => no prefix)
    # * <tt>:slim</tt> - If set to <tt>true</tt> no shortcut methods for all enumeration values are being genereated
    #   (default is <tt>nil</tt> => they are generated)
    # * <tt>:whiny</tt> - Boolean value which if set to <tt>true</tt> will throw an <tt>ArgumentError</tt>
    #   if an invalid value is passed to the setter (e.g. a value for which no enumeration exists). if set to
    #   <tt>false</tt> no exception is thrown and the internal value is set to <tt>nil</tt> (default is <tt>true</tt>)    
    def as_enum(enum_cd, values, options = {})
      options = { :column => "#{enum_cd}_cd", :whiny => true }.merge(options)
      options.assert_valid_keys(:column, :whiny, :prefix, :slim)
      
      # convert array to hash...
      values = Hash[*values.enum_with_index.to_a.flatten] unless values.respond_to?('invert')
      values_inverted = values.invert
      
      # store info away
      write_inheritable_attribute(:enum_definitions, {}) if enum_definitions.nil?
      enum_definitions[enum_cd] = enum_definitions[options[:column]] = { :name => enum_cd, :column => options[:column], :options => options }
      
      # generate getter       
      define_method("#{enum_cd}") do
        id = read_attribute options[:column]
        values_inverted[id]
      end
      
      # generate setter
      define_method("#{enum_cd}=") do |new_value|
        v = new_value.nil? ? nil : values[new_value.to_sym]        
        raise(ArgumentError, "Invalid enumeration value: #{new_value}") if (options[:whiny] and v.nil? and !new_value.nil?)
        write_attribute options[:column], v
      end
      
      # DEPRECATED: allow "simple" access to defined values-hash, e.g. in select helper.
      define_method("values_for_#{enum_cd}") do
        warn "DEPRECATION WARNING: `obj.values_for_#{enum_cd}` is deprecated. Please use `#{self.class}.#{enum_cd.to_s.pluralize}` instead (called from: #{caller.first})"
        values.clone
      end
      
      # allow access to defined values hash, e.g. in a select helper or finder method.
      metaclass = class << self; self; end
      class_variable_set :"@@SE_#{enum_cd.to_s.pluralize.upcase}", values
      class_eval(<<-EOM, __FILE__, __LINE__ + 1)
        def self.#{enum_cd.to_s.pluralize}(sym = nil)
          return class_variable_get(:@@SE_#{enum_cd.to_s.pluralize.upcase}) if sym.nil?
          class_variable_get(:@@SE_#{enum_cd.to_s.pluralize.upcase})[sym]
        end
      EOM
      
      # only create if :slim is not defined
      unless options[:slim]
        # create both, boolean operations and *bang* operations for each
        # enum "value"
        prefix = options[:prefix] && "#{options[:prefix] == true ? enum_cd : options[:prefix]}_"
      
        values.each do |sym,code|                    
          define_method("#{prefix}#{sym}?") do
            code == read_attribute(options[:column])
          end
          define_method("#{prefix}#{sym}!") do
            write_attribute options[:column], code
            sym
          end
          
          # allow class access to each value
          metaclass.send(:define_method, "#{prefix}#{sym}", Proc.new { code })
        end
      end
    end
    
    # Validates an +as_enum+ field based on the value of it's column.
    #
    # Model:
    #    class User < ActiveRecord::Base
    #      as_enum :gender, [ :male, :female ]
    #      validates_as_enum :gender
    #    end
    #
    # View:
    #    <%= select(:user, :gender, User.genders.keys) %>
    #
    # Configuration options:
    # * <tt>:message</tt> - A custom error message (default: is <tt>[:activerecord, :errors, :messages, :invalid_enum]</tt>).
    # * <tt>:on</tt> - Specifies when this validation is active (default is <tt>:save</tt>, other options <tt>:create</tt>, <tt>:update</tt>).
    # * <tt>:if</tt> - Specifies a method, proc or string to call to determine if the validation should
    #   occur (e.g. <tt>:if => :allow_validation</tt>, or <tt>:if => Proc.new { |user| user.signup_step > 2 }</tt>). The
    #   method, proc or string should return or evaluate to a true or false value.
    # * <tt>:unless</tt> - Specifies a method, proc or string to call to determine if the validation should
    #   not occur (e.g. <tt>:unless => :skip_validation</tt>, or <tt>:unless => Proc.new { |user| user.signup_step <= 2 }</tt>). The
    #   method, proc or string should return or evaluate to a true or false value.
    def validates_as_enum(*attr_names)
      configuration = { :on => :save }
      configuration.update(attr_names.extract_options!)      
      attr_names.map! { |e| enum_definitions[e][:column] } # map to column name
      
      validates_each(attr_names, configuration) do |record, attr_name, value|
        enum_def = enum_definitions[attr_name]
        unless send(enum_def[:name].to_s.pluralize).values.include?(value)
          record.errors.add(enum_def[:name], :invalid_enum, :default => configuration[:message], :value => value)
        end
      end
    end
    
    protected
      # Returns enum definitions as defined by each call to
      # +as_enum+.
      def enum_definitions #:nodoc:
        read_inheritable_attribute(:enum_definitions)
      end
  end
end

# Tie stuff together and load translations
if Object.const_defined?('ActiveRecord')
  ActiveRecord::Base.send(:include, SimpleEnum)
  I18n.load_path << File.join(File.dirname(__FILE__), '..', 'locales', 'en.yml')  
end