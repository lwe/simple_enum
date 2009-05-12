SimpleEnum
==========

SimpleEnum tries to bring an easy-to-use enum-like functionality to ActiveRecord.

**NOTE**: this code seems to work very well for me, though I must admit I'm a RoR newbee, so maybe
I've written code which could be rewritten :)

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

Now you it's possible to pull some neat tricks on the new column:

    @user = User.new
    @user.gender = :female
    @user.female?   # => true
    @user.gender    # => :female
    @user.gender_cd # => 1
    
Wait, there's more
------------------

-> Too tired of always adding the integer values? Try:

    class User < ActiveRecord::Base
      as_enum :status, [:deleted, :active, :disabled] # translates to :deleted => 0, :active => 1, :disabled => 2
    end

**Disclaimer**: if you _ever_ decide to reorder this array, beaware that any previous mapping is lost. So it's recommended
to create mappings (that might change) using hashes instead of arrays. For stuff like gender it might be probably perfectly
fine to use arrays though.

-> Maybe you've columns named differently than the proposed `{column}_cd` naming scheme, feel free to use any column name
by providing an option:

    class User < ActiveRecord::Base
      as_enum :gender, [:male, :female], :column => 'sex'
    end

Known issues
------------

* Mass assignments like in:

        @user = User.new params[:user]
        
    do not work (yet?!) However setting the `_cd` field of course works as expected,
  so for the user example above, if a `gender_cd` field exists with an integer value
  it's perfectly fine and even mass-assignments work.
