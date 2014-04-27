SimpleEnum
==========

[![Build Status](https://travis-ci.org/lwe/simple_enum.svg?branch=lwe-v2)](https://travis-ci.org/lwe/simple_enum)
[![Code Climate](https://codeclimate.com/github/lwe/simple_enum.png)](https://codeclimate.com/github/lwe/simple_enum)

Unobtrusive enum-like fields for ActiveRecord and Ruby, brings enums functionality
to ActiveRecord and Mongoid models (built for Rails 4+).

Since version 2.0, simple_enum is no longer compatible with Rails 3.x or Ruby 1.8,
use version 1.6 instead: https://github.com/lwe/simple_enum/tree/v1.6.7

*Note*: a recent search on github for `enum` turned out, that there are many,
many similar solutions. In fact starting with Rails 4.1, there's `ActiveRecord::Enum`
which provides **some** of the functionality.

ActiveRecord Quick start
------------------------

Add this to a model:

```ruby
class User < ActiveRecord::Base
  as_enum :gender, female: 1, male: 0
end
```

Then create the required `gender_cd` column using migrations:

```ruby
class AddGenderColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :gender_cd, :integer
  end

  def self.down
    remove_column :users, :gender_cd
  end
end
```

Mongoid Quick start
-------------------

Add this to an initializer

```ruby
 # load mongoid support
 require 'simple_enum/mongoid'
```

Add this to a model:

```ruby
class User
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :gender, female: 1, male: 0
end
```

Working with enums
------------------

Now it's possible to pull some neat tricks on the new column, yet the original
db column (`gender_cd`) is still intact and not touched by any fancy metaclass
or similar.

```ruby
jane = User.new
jane.gender = :female
jane.female?   # => true
jane.male?     # => false
jane.gender    # => :female
jane.gender_cd # => 1
```

Easily switch to another value using the bang methods.

```ruby
joe = User.new
joe.male!     # => :male
joe.gender    # => :male
joe.gender_cd # => 0
```

There are even some neat tricks at class level, which might be
useful when creating queries, displaying option elements or similar:

```ruby
User.genders            # => { "male" => 0, "female" => 1 } - HashWithIndifferentAccess
User.genders[:male]     # => 0
User.female             # => #<ActiveRecord::Relation:0x0.....>
```

### Wait, there's more!
* Too tired of always adding the integer values? Try:

        class User < ActiveRecord::Base
          as_enum :status, [:deleted, :active, :disabled] # translates to :deleted => 0, :active => 1, :disabled => 2
        end

  *Disclaimer*: if you _ever_ decide to reorder this array, beaware that any previous mapping is lost. So it's recommended
  to create mappings (that might change) using hashes instead of arrays. For stuff like gender it might be probably perfectly
  fine to use arrays though.
* You can use string values instead of integer values if your database column has the type +string+ or +text+:

       class User < ActiveRecord::Base
         as_enum :status, [:deleted, :active, :disabled], :strings => true
       end

       User.create!(status: :active) #=> #<User id: 1, status_cd: "active">
* Want to use `SimpleEnum` in an ActiveModel, or other class, just do:

        class MyModel
          include SimpleEnum
          attr_accessor :gender_cd
          as_enum :gender, [:male, :female]
        end

* Maybe you've columns named differently than the proposed <tt>{column}_cd</tt> naming scheme, feel free to use any column name
  by providing an option:

        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female], :column => 'sex'
        end

  It's not allowed to use the same column name as the enum name, this has been deprecated since 1.4.x and will be
  removed in 1.6.x.
* Want support for ActiveRecords dirty attributes, provide <tt>:dirty => true</tt> as option, which automatically adds both
  the <tt>{enum}_changed?</tt> and <tt>{enum}_was</tt> methods, which delegate to ActiveRecord.

        class User < ActiveRecord::Base
            as_enum :gender, [:male, :female], :dirty => true
        end

        @user = User.where(:gender_cd => User.male).first
        @user.gender = :female
        @user.gender_was
        # => :male

* Need to provide custom options for the mongoid field, or skip the automatically generated field?

        # skip field generation
        field :gender_cd # <- create field manually (!)
        as_enum :gender, [:male, :female], :field => false

        # custom field options (directly passed to Mongoid::Document#field)
        as_enum :gender, [:male, :female], :field => { :type => Integer, :default => 1 }

* It's possible to validate the internal enum values, just like any other ActiveRecord validation:

        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female]
          validates :gender, :as_enum => true
          # OR validates_as_enum :gender
        end

  All common options like <tt>:if</tt>, <tt>:unless</tt>, <tt>:allow_nil</tt> and <tt>:message</tt> are supported, because it just works within
  the standard <tt>validates_each</tt>-loop. This validation method does not check the value of <tt>user.gender</tt>, but
  instead the value of <tt>@user.gender_cd</tt>.
* If the shortcut methods (like <tt><symbol>?</tt>, <tt><symbol>!</tt> or <tt>Klass.<symbol></tt>) conflict with something in your class, it's possible to
  define a prefix:

        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female], :prefix => true
        end

        jane = User.new :gender => :female
        jane.gender_female? # => true
        User.gender_female  # => 1, this also works on the class methods

  The <tt>:prefix</tt> option not only takes a boolean value as an argument, but instead can also be supplied a custom
  prefix (i.e. any string or symbol), so with <tt>:prefix => 'foo'</tt> all shortcut methods would look like: <tt>foo_<symbol>...</tt>
  *Note*: if the <tt>:slim => true</tt> is defined, this option has no effect whatsoever (because no shortcut methods are generated).
* Sometimes it might be useful to disable the generation of the shortcut methods (<tt><symbol>?</tt>, <tt><symbol>!</tt> and <tt>Klass.<symbol></tt>),
  to do so just add the option <tt>:slim => true</tt>:

        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female], :slim => true
        end

        jane = User.new :gender => :female
        jane.female? # => throws NoMethodError: undefined method `female?'
        User.male    # => throws NoMethodError: undefined method `male'

  Yet the setter and getter for <tt>gender</tt>, as well as the <tt>User.genders</tt> methods are still available, only all shortcut
  methods for each of the enumeration values are not generated.

  It's also possible to set <tt>:slim => :class</tt> which only disables the generation of any class-level shortcut method, because those
  are also available via the enhanced enumeration hash:

        class Message < ActiveRecord::Base
          as_enum :status, { :unread => 0, :read => 1, :archived => 99 }, :slim => :class
        end

        msg = Message.new :body => 'Hello World!', status_cd => 0
        msg.read?                      # => false; shortuct methods on instance are still enabled
        msg.status                     # => :unread
        Message.unread                 # => throws NoMethodError: undefined method `unread`
        Message.statuses.unread        # => 0
        Message.statuses.unread(true)  # => :unread

        # or useful for IN queries
        Messages.statuses(:unread, :read) # => [0, 1]

* As a default an <tt>ArgumentError</tt> is raised if the user tries to set the field to an invalid enumeration value, to change this
  behaviour use the <tt>:whiny</tt> option:

        class User < ActiveRecord::Base
          as_enum :gender, [:male, :female], :whiny => false
        end

* To make it easier to create dropdowns with values use:

        <%= select(:user, :gender, User.genders.keys) %>

* Need translated keys et al in your forms? SimpleEnum provides a <tt><enum>_for_select</tt> method:

       # on the gender field
       <%= select("user", "gender", User.genders_for_select) %>

       # or on the '_cd' field
       <%= select("user", "gender_cd", User.genders_for_select(:value))

  Translations need to be stored like:

       de:
         activerecord:
           enums:
             user:              # the Model, as User.class.name.underscore
               genders:         # pluralized version of :gender
                 male: männlich
                 female: weiblich

* To define any option globally, like setting <tt>:whiny</tt> to +false+, or globally enable <tt>:prefix</tt>; all default options
  are stored in <tt>SimpleEnum.default_options</tt>, this hash can be easily changed in your initializers or wherever:

        # e.g. setting :prefix => true (globally)
        SimpleEnum.default_options[:prefix] = true

## Best practices

Do not use states named after existing, or well known method names, like `new` or `create`, e.g.

```ruby
# BAD, conflicts with Rails ActiveRecord Methods (!)
as_enum :handle, [:new, :create, :update]

# GOOD, prefixes all methods
as_enum :handle, [:new, :create, :update], :prefix => true
```

Searching for certain values by using the finder methods:

```ruby
User.female
```

Working with database backed values, now assuming that there exists a +genders+ table:

    class Person < ActiveRecord::Base
      as_enum :gender, Gender.all.map { |g| [g.name.to_sym, g.id] } # map to array of symbols
    end

Working with object backed values, the only requirement to enable this is that <em>a)</em> either a field name +name+ exists
or <em>b)</em> a custom method to convert an object to a symbolized form named +to_enum_sym+ (for general uses overriding
+to_enum+ is perfectly fine) exists:

    class Status < ActiveRecord::Base
      # this has a column named :name
      STATUSES = self.order(:name)
    end

    class BankTransaction < ActiveRecord::Base
      as_enum :status, Status::STATUSES
    end

    # what happens now? the id's of Status now serve as enumeration key and the
    # Status object as the value so...
    t = BankTransaction.new
    t.pending!
    t.status # => #<Status id: 1, name: "pending">

    # and it's also possible to access the objects/values using:
    BankTransaction.statuses(:pending) # => 1, access by symbol (not) the object!
    BankTransaction.statuses.pending   # => 1
    BankTransaction.statuses.pending(true) # => #<Status id: 1, name: "pending">

Contributors
------------

* @dmitry - bugfixes and other improvements
* @tarsolya - implemented all the ruby 1.9 and rails 3 goodness!
* @dbalatero - rails 2.3.5 bugfix & validator fixes
* @johnthethird - feature for <tt>_for_select</tt> to return the values
* @sinsiliux - ruby 1.9 fixes and removed AR dependency
* @sled - mongoid support
* @abrom - <tt>find_by_...</tt> method
* @mhuggins - translations fixes
* @patbenatar - for helping move towards 2.0 (scopes et all)
* and all others: https://github.com/lwe/simple_enum/graphs/contributors thanks

License & Copyright
-------------------

Copyright (c) 2011-2014 by Lukas Westermann, Licensed under MIT Licence (see LICENCE file)
