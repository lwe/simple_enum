SimpleEnum
==========

[![Build Status](https://travis-ci.org/lwe/simple_enum.svg)](https://travis-ci.org/lwe/simple_enum)
[![Code Climate](https://codeclimate.com/github/lwe/simple_enum.svg)](https://codeclimate.com/github/lwe/simple_enum)

Unobtrusive enum-like fields for ActiveRecord and Ruby, brings enums functionality
to ActiveRecord and Mongoid models (built for Rails 4+).

Since version 2.0, simple_enum is no longer compatible with Rails 3.x or Ruby 1.8,
use version 1.6 instead: https://github.com/lwe/simple_enum/tree/legacy-1.x

*Note*: a recent search on github for `enum` turned out, that there are many,
many similar solutions. In fact starting with Rails 4.1, there's `ActiveRecord::Enum`
which provides **some** of the functionality, but is IMHO pretty limited and too
strict in the defaults it provides.

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

Due to the dependency on ActiveModel 4.x, the Mongoid integration is only
available for mongoid 4.0.0 (which is at beta1 at the moment). If you intend
to use simple_enum with another version of mongoid, use version 1.6 instead.

Load mongoid support in the `Gemfile`:

```ruby
gem 'simple_enum', '~> 2.3.0' , require: 'simple_enum/mongoid'
```

Add this to a model:

```ruby
class User
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :gender, female: 1, male: 0
end
```

The primary difference between AR and mongoid is, that additionaly a field is
added to mongoid automatically, the field can be customized by setting `field:`
option, or disabled by setting `field: false`.

Working with enums
------------------

Now it's possible to pull some neat tricks on the new column, yet the original
db column (`gender_cd`) is still intact and not touched by anything.

```ruby
jane = User.new
jane.gender = :female
jane.female?   # => true
jane.male?     # => false
jane.gender    # => :female
jane.gender_cd # => 1
```

Easily switch to another value using the bang methods, this does not save
the record, only switch the value.

```ruby
joe = User.new
joe.male!     # => :male
joe.gender    # => :male
joe.gender_cd # => 0
```

Accessing actual enum values is possible at the class level:

```ruby
User.genders                            # => #<SimpleEnum::Enum:0x0....>
User.genders[:male]                     # => 0
User.genders.values_at(:male, :female)  # => [0, 1] (since 2.1.0)
User.females                            # => #<ActiveRecord::Relation:0x0.....> (WHERE gender_cd = 1)
```

### Wait, there's more!

- Too tired of always adding the integer values? Try:

  ```ruby
  class User < ActiveRecord::Base
    as_enum :status, %i{deleted active disabled}
    # translates to: { deleted: 0, active: 1, disabled: 2 }
  end
  ```

  **Disclaimer**: if you _ever_ decide to reorder this array, beware that any
  previous mapping is lost. So it's recommended to create mappings (that might
  change) using hashes instead of arrays. For stuff like gender it might be
  probably perfectly fine to use arrays though.
- You can store as string values instead of integer values if your database column
  has the type `string` or `text`:

  ```ruby
  class User < ActiveRecord::Base
    as_enum :status, [:deleted, :active, :disabled], map: :string
  end

  User.create!(status: :active) #=> #<User id: 1, status_cd: "active">
  ```
- Want to use `SimpleEnum` in an ActiveModel, or other class, just add:

  ```ruby
  class MyModel
    extend SimpleEnum::Attribute
    attr_accessor :gender_cd
    as_enum :gender, [:male, :female]
  end
  ```
- Maybe you've columns named differently than the proposed `{column}_cd` naming scheme, feel free to use any column name
  by providing an option:

  ```ruby
  class User < ActiveRecord::Base
    as_enum :gender, [:male, :female], source: :sex
  end
  ```

  Starting with 2.0 it's possible to use the same source name as column name.
- By default ActiveRecord dirty methods are generated:

  ```ruby
  user = User.male.first
  user.gender = :female
  user.gender_was
  # => :male
  ```
- Need to provide custom options for the mongoid field, or skip the automatically generated field?

  ```ruby
  # skip field generation
  field :gender_cd # <- create field manually (!)
  as_enum :gender, [:male, :female], field: false

  # custom field options (directly passed to Mongoid::Document#field)
  as_enum :gender, [:male, :female], field: { :type => Integer, :default => 1 }
  ```
- To validate enum values simply make use of a `validates :gender, presence: true` validation.
  If an invalid value is assigned, the gender is set to `nil` by default.
- If the shortcut methods (like `female?`, `female!` or `User.male`) conflict with something in your class, it's possible to
  define a prefix:
  ```ruby
  class User < ActiveRecord::Base
    as_enum :gender, %w{male female}, prefix: true
  end

  jane = User.new gender: :female
  jane.gender_female? # => true
  User.gender_females  # => <ActiveRecord::Relation...WHERE gender_cd = 1.>
  ```
  The `:prefix` option not only takes a boolean value as an argument, but instead can also be supplied a custom
  prefix, so with `prefix: 'foo'` all shortcut methods would look like: `foo_<symbol>`
- To define which methods are generated it's possible to set `with:` option, by
  default `with:` is set to `[:attribute, :dirty, :scope]`.

  1. `:attribute` - generates the `male?` and `male!` accessor methods
  2. `:dirty` - adds the `gender_was` and `gender_changed?` dirty methods
  3. `:scope` - adds the class level scopes, **if** the `scope` method is present

- By default the value is set to `nil` when the user sets an invalid value,
  this behavior can be changed by setting the `accessor:` option. At the moment
  there are three different behaviors:

  1. `:default` - which sets the value simply to `nil`
  2. `:whiny` - raises an ArgumentError when trying to set an invalid value
  3. `:ignore` - keeps the existing value

  ```ruby
  class User < ActiveRecord::Base
    as_enum :gender, %w{male female}, accessor: :whiny
  end
  User.new(gender: "dunno") # => raises ArgumentError
  ```

  See `lib/simple_enum/accessors/*` for more.

- To define any option globally, e.g. never generating dirty methods, create
  an initializer and add:

  ```ruby
  # See lib/simple_enum.rb for other options
  SimpleEnum.with = [:attribute, :scope]
  ```

### View Helpers

Require translated enum values? See [SimpleEnum::ViewHelpers][VE.rb] for more
details and functions. _Disclaimer_: these methods are release candidate quality
so expect them to change in future versions of SimpleEnum.

- Translate the current value in a view:

  ```ruby
  translate_enum user, :gender # => "Frau" # assuming :de and translations exist
  te user, :gender # translate_enum is also aliased to te
  ```
  
  Provide translations in the i18n yaml file like:
  
  ```ruby
    de:
      enums:
        gender:
          female: 'Frau'
          male: 'Mann'
  ```
  
- Build a select tag with a translated dropdown and symbol as value:

  ```ruby
  select :user, :gender, enum_option_pairs(User, :gender)
  ```
  
- ...and one with the index as value:

  ```ruby
  select :user, :gender_cd, enum_option_pairs(User, :gender, true)
  ```

## Extensions

`simple_enum` provides hooks to extend its functionality, starting with 2.3.0
the following extensions can be used:

- **Multi-select enum** support for SimpleEnum:
  [simple_enum-multiple](https://github.com/bbtfr/simple_enum-multiple)
- **Persistence values**, i.e. store values in the DB:
  [simple_enum-persistence](https://github.com/bbtfr/simple_enum-persistence)

## Best practices

Do not use values named after existing, or well known method names, like `new`, `create` etc.

```ruby
# BAD, conflicts with Rails ActiveRecord Methods (!)
as_enum :handle, [:new, :create, :update]

# GOOD, prefixes all methods
as_enum :handle, [:new, :create, :update], prefix: true
```

Searching for certain values by using the finder methods:

```ruby
User.females # => returns an ActiveRecord::Relation
```

Contributors
------------

- [@dmitry](https://github.com/dmitry) - bugfixes and other improvements
- [@tarsolya](https://github.com/tarsolya) - implemented all the ruby 1.9 and rails 3 goodness!
- [@dbalatero](https://github.com/dbalatero) - rails 2.3.5 bugfix & validator fixes
- [@johnthethird](https://github.com/johnthethird) - feature for `_for_select` to return the values
- @sinsiliux - ruby 1.9 fixes and removed AR dependency
- [@sled](https://github.com/sled) - mongoid support
- [@abrom](https://github.com/abrom) - `find_by_...` method
- [@mhuggins](https://github.com/mhuggins) - translations fixes
- [@patbenatar](https://github.com/patbenatar) - for helping move towards 2.0 (scopes et all)
- [@abacha](https://github.com/abacha) - translation helpers, README fixes
- [@bbtfr](https://github.com/bbtfr) - for support, ideas and pushing extensions
- and all others: https://github.com/lwe/simple_enum/graphs/contributors thanks

License & Copyright
-------------------

Copyright (c) 2011-2015 by Lukas Westermann, Licensed under MIT License (see LICENSE file)

[VE.rb]: https://github.com/lwe/simple_enum/blob/master/lib/simple_enum/view_helpers.rb
