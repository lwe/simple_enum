SimpleEnum
==========

SimpleEnum tries to bring an easy-to-use enum-like functionality to ActiveRecord.

**NOTE**: this code seems to work very well for me, though I must admit I'm a RoR newbee, so your mileage may vary

Quick start
-----------

In your model:

    class User < ActiveRecord::Base
      as_enum :gender, {:female => 1, :male => 0}
    end
  
In your migrations:

    class AddGenderColumnsToUser < ActiveRecord::Migration
      def self.up
        add_column :users, :gender_cd, :integer
      end
    
      def self.down
        remove_column :users, :gender_cd
      end
    end

Now it's possible to pull some neat tricks on the new column:

    jane = User.new
    jane.gender = :female
    jane.female?   # => true
    jane.male?     # => false
    jane.gender    # => :female
    jane.gender_cd # => 1
    
Wait, there's more
------------------

* Too tired of always adding the integer values? Try:

        class User < ActiveRecord::Base
          as_enum :status, [:deleted, :active, :disabled] # translates to :deleted => 0, :active => 1, :disabled => 2
        end

    **Disclaimer**: if you _ever_ decide to reorder this array, beaware that any previous mapping is lost. So it's recommended
    to create mappings (that might change) using hashes instead of arrays. For stuff like gender it might be probably perfectly
    fine to use arrays though.

* Maybe you've columns named differently than the proposed `{column}_cd` naming scheme, feel free to use any column name
  by providing an option:

        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female], :column => 'sex'
        end
        
* To make it easier to create dropdowns with values use:

        <%= select(:user, :gender, @user.values_for_gender.keys) %>
        
* It's possible to validate the internal enum values, just like any other ActiveRecord validation:

        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female]
          validates_as_enum :gender
        end

    All common options like `:if`, `:unless`, `:allow_nil` and `:message` are supported, because it just works within
    the standard `validates_each`-loop. This validation method does not check the value of `@user.gender`, but
    instead the value of `@user.gender_cd`.
    
* If the shortcut methods (like `<symbol>?` or `<symbol>!`) conflict with something in your class, it's possible to
  define a prefix:
  
        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female], :prefix => true
        end

        jane = User.new :gender => :female
        jane.gender_female? # => true
        
    The `:prefix` option not only takes a boolean value as an argument, but instead can also be supplied a custom
    prefix (i.e. any string or symbol), so with `:prefix => 'foo'` all shortcut methods would look like: `foo_<symbol>...`
    **Note**: if the `:slim => true` is defined, this option has no effect whatsoever (because no shortcut methods are generated).
    
* Sometimes it might be useful to disable the generation of the shortcut methods (`<symbol>?` and `<symbol>!`), to do so just
  add the option `:slim => true`:
  
        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female], :slim => true
        end

        jane = User.new :gender => :female
        jane.female? # => throws NoMethodError: undefined method `female?' 
  
    Yet the setter and getter for `gender`, as well as the `values_for_gender` methods are still available, only all shortcut
    methods for each of the enumeration values are not generated.
  
* As a default an `ArgumentError` is raised if the user tries to set the field to an invalid enumeration value, to change this
  behaviour use the `:whiny` option:
  
        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female], :whiny => false
        end
    
Known issues/Open items
-----------------------
  
* Maybe the `:whiny` option should default to `false`, so that generally no exceptions are thrown if a user fakes a request?
* Make class independent of `ActiveRecord` where possible (so that atleast as_enum works!)