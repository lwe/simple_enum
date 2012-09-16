---
layout: default
title: "Using simple_enum with Rails - simple_enum"
excerpt: "Guide for setting up and using simple_enum with Rails and ActiveRecord."
---

# Using simple_enum with Rails

If you've added simple_enum to your Gemfile and you are using ActiveRecord, simple_enum
works out of to box. Enumeration columns can then be specified with either an Array or Hash.

<ol>
  <li>
    Add a <em>code</em> column to hold the enum value to your table using migrations:
{% highlight ruby %}
# Colum names should be named like {{ "{{enum_name" }}}}_cd
add_column :users, :gender_cd, :integer
{% endhighlight %}
  </li>
  <li>
    Add <code>as_enum</code> to your model:
{% highlight ruby %}
class User < ActiveRecord::Base
  # Using a Hash (recommended):
  as_enum :gender, :female => 1, :male => 0

  # OR using an Array:
  # as_enum :gender, %w{male female}
end
{% endhighlight %}
  </li>
  <li>
    Yeah, done!
{% highlight ruby %}
person = Person.new(:gender => :female)
person.female?   # => true
person.gender    # => :female
person.gender_cd # => 1
{% endhighlight %}
  </li>
</ol>

## Custom column names

Changing the source for an enum can easily be achived by using the `:column` option
for `as_enum`, using this it's possible to use arbitary column names.

**Note:** it is not valid to use a column name which has the same name as the enum.

{% highlight ruby %}
class User < ActiveRecord::Base
  # OK:
  as_enum :gender, %w{male female}, :column => 'sex'

  # BAD (throws ArgumentError):
  # as_enum :sex, %w{male female}, :column => 'sex'
end
{% endhighlight %}
