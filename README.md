SimpleEnum
==========

SimpleEnum tries to bring an easy-to-use enum-like functionality to ActiveRecord.

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

Known issues
------------

* Mass assignments like in:

        @user = User.new params[:user]
        
  do not work (yet?!) However setting the `_cd` field of course works as expected,
  so for the user example above, if a `gender_cd` field exists with an integer value
  it's perfectly fine and even mass-assignments work.
