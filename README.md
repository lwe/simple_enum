SimpleEnum - simple enum-like attributes
========================================

Simply provides enum-like attributes for your models, including plain old ruby objects,
ActiveRecord or Mongoid. Version 2.0 is a complete rewrite, using a more modular approach
and streamlined API.

Since 2.0 is not fully backwards compatible, simple_enum 1.6 will be maintained for some
time, see https://github.com/lwe/simple_enum/tree/v1.6.4

**Note**: a search on github for `enum` turns out, that there are many, many similar solutions.

Installation
------------

It's a gem so just add `gem "simple_enum"` to your `Gemfile` and run `bundle`. If you are using Rails
that's it, otherwise ensure to `require "simple_enum"` somewhere.

### ActiveRecord Quick start

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

### Mongoid Quick start

Add this to an initializer:

```ruby
# load mongoid support
require 'simple_enum/integration/mongoid'
```

Add this to a model:

```ruby
class User
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :gender, female: 1, male: 0
end
```

Usage
-----

Information
-----------

Contributors
------------

- @dmitry - bugfixes and other improvements
- @tarsolya - implemented all the ruby 1.9 and rails 3 goodness!
- @dbalatero - rails 2.3.5 bugfix & validator fixes
- @johnthethird - feature for _for_select to return the values
- @sinsiliux - ruby 1.9 fixes and removed AR dependency
- @sled - mongoid support
- @noiseunion - for helping me start on 2.0
- and all others: https://github.com/lwe/simple_enum/graphs/contributors thanks

Licence
-------

MIT Licence, Copyright 2011-2013 by Lukas Westermann (see LICENCE file)

