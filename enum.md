---
layout: default
title: "Configuration and options - simple_enum"
excerpt: "Guide for integrating simple_enum with Mongoid."
---

# Configuring simple_enum

Different options to `as_enum` can be provided to change the behavior, basic
usage is like:

{% highlight ruby %}
as_enum :enum_name, # Name of enum, the column is {{ "{{enum_name" }}}}_cd
        Array/Hash, # Enum values as either Hash or Array
        Hash        # (Optional) Hash with options for enum
{% endhighlight %}

## Options for as_enum

<dl>
  <dt><code>column: String</code></dt>
  <dd>
    <p>
      Set the name of the column to store the value in, defaults to
      <code>{{ "{{enum_name" }}}}_cd</code>.
    </p>
    <p>
      <strong>Note</strong> It is not allowed to use the same column name as the enum name, this will
      throw an exception.
    </p>

{% highlight ruby %}
# Store value in sex, instead of gender_cd
as_enum :gender, %w{male female}, column: 'sex'

# Example:
user = User.new(sex: 1)
user.gender # => 'male'
user.sex    # => 1
{% endhighlight %}
  </dd>

  <dt><code>dirty: true</code></dt>
  <dd>
    <p>
      When set to true generates <code>{{ "{{enum_name" }}}}_was</code> and
      <code>{{ "{{enum_name" }}}}_changed?</code> methods for the enum, which
      delegate to the internal column.
    </p>
    <p>
      Defaults to <code>false</code>.
    </p>

{% highlight ruby %}
# Enable dirty attributes
as_enum :service, %w{twitter facebook google}, dirty: true

# Example:
user = User.new(service: :twitter)
user.service = :google
user.service_was      # => :twitter
user.service_changed? # => true
{% endhighlight %}
  </dd>

  <dt><code>prefix: true/String</code></dt>
  <dd>
    <p>
      Define a prefix, which is prepended to shortcut methods (e.g. <code>{{ "{{symbol" }}}}!</code> and <code>{{ "{{symbol" }}}}?</code>),
      if it's set to <code>true</code> the enum name is used as prefix, else the custom supplied String.
    </p>
    <p>
      Defaults to <code>nil</code>, i.e. no prefix.
    </p>

{% highlight ruby %}
# Use custom prefix
as_enum :gender, %w{male female}, prefix: 'sex'

# Use enum name as prefix
as_enum :service, %w{twitter facebook google}, prefix: true

# Example:
user = User.new(service: :twitter, gender: :female)

user.sex_female?       # => true

user.service_twitter?  # => true
user.service_google!   # => true
user.service           # => :google
{% endhighlight %}
  </dd>
</dl>

## Enum values

The enum values can either be provided as Array or a Hash. When using a Hash, the
Hash key is the enum symbol and the Hash value is stored in the column. Hashes are
favored over Arrays, because when using Arrays the 0-based index of the value is
stored in the column.

> **Disclaimer** When using Arrays ensure to never reorder it or remove items,
> because this would change the index.

{% highlight ruby %}
# **Hash** with values, uses hash key as enum symbol and the value is
# stored in service_cd.
#
# So when setting the value to e.g. `:facebook`, `1` is stored
# in service_cd.
as_enum :service, { twitter: 0, facebook: 1, google: 2 }

# **Array** of values, stores index of values in service_cd.
#
# So when setting the value to e.g. `:facebook`, `1` is stored
# in service_cd.
as_enum :service, [:twitter, :facebook, :google]

# **Array** of values, but storing strings in service_cd, by setting the
# `:strings` options to true.
#
# So when setting the value to e.g. `:facebook`, `facebook` is stored
# in service_cd column.
as_enum :service, [:twitter, :facebook, :google], strings: true
{% endhighlight %}
