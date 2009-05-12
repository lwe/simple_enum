module SimpleEnum #:nodoc:
  
  def self.included(base)
    base.send :extend, ClassMethods
  end
  
  module ClassMethods #:nodoc:
    
    # Provides ability to create simple enumerations based on hashes or arrays, backed
    # by integer columns.
    #
    # Columns are supposed to be suffixed by =_cd=, if not, use <tt>:column => 'the_column_name'</tt>,
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
    # It automatically creates some useful methods:
    #
    #   @user = User.new
    #   @user.gender          # => nil
    #   @user.gender = :male
    #   @user.gender          # => :male
    #   @user.gender_cd       # => 0
    #   @user.male?           # => true
    #   @user.female?         # => false
    #   @user.female!         # => :female (set's gender to :female => gender_cd = 1)
    #   @user.male?           # => false
    #
    # To access the key/value assocations in a helper like the select helper or similar use:
    #
    #   <%= select(:user, :gender_cd, @user.values_for_gender)
    #
    # Note that the form attribute used is not :gender, but :gender_cd, this is due
    # to the fact that I don't know how to hack into the attributes= method to make
    # that happen :) and I don't think it's a good idea to do so anyway.
    def as_enum(enum_cd, values, options = {})
      options = { :column => "#{enum_cd.to_s}_cd" }.merge(options)
      options.assert_valid_keys(:column)
      
      # convert array to hash...
      values = Hash[*values.enum_with_index.to_a.flatten] unless values.respond_to?('invert')
      
      # generate getter       
      define_method(enum_cd.to_s) do
        id = read_attribute options[:column]
        values.invert[id]
      end
      
      # generate setter
      define_method("#{enum_cd.to_s}=") do |new_value|            
        write_attribute options[:column], values[new_value]
      end
      
      # allow "simple" access to defined values-hash, e.g. in select helper.
      define_method("values_for_#{enum_cd.to_s}") do
        values.clone
      end
      
      # create both, boolean operations and *bang* operations for each
      # enum "value"
      values.each do |k,cd|
        define_method("#{k.to_s}?") do
          cd == read_attribute(options[:column])
        end
        define_method("#{k.to_s}!") do
          write_attribute options[:column], cd
          k
        end
      end
    end
  end
end

# Tie stuff together.
if Object.const_defined?('ActiveRecord')
  ActiveRecord::Base.send(:include, SimpleEnum)
end