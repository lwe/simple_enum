---
layout: default
title: "simple_enum: enum fields for ruby"
excerpt: "Simple enum-like field support for Ruby, ActiveRecord and Mongoid, including validation and internationalization."
downloads: true
---

# Getting started

Starting with simple_enum is as easy as adding this line to your application's Gemfile:

{% highlight ruby %}
gem 'simple_enum'
{% endhighlight %}

And then execute `bundle` or install it yourself: `gem install simple_enum`.

## Rails integration

[→ Using simple_enum with ActiveRecord](rails.html)<br>
[→ Defining custom column names](rails.html#Custom+column+names)

## Mongoid usage

[→ Using simple_enum with Mongoid](mongoid.html)<br>

# Configuring simple_enum

Different options to `as_enum` can be provided to change the behavior, basic
usage is like:

{% highlight ruby %}
as_enum :enum_name, # Name of enum, the column is {{ "{{enum_name" }}}}_cd
        Array/Hash, # Enum values as either Hash or Array
        Hash        # (Optional) Hash with options for enum
{% endhighlight %}

## Options

<ul>
  <li>
    <p>
      <code>:column => String</code> Set the name of the column to store the value in, defaults to
      <code>{{ "{{enum_name" }}}}_cd</code>.
    </p>
    <p>
      <strong>Note</strong> It is not allowed to use the same column name as the enum name, this will
      throw an exception.
    </p>
{% highlight ruby %}
# Store value in sex, instead of gender_cd
as_enum :gender, %w{male female}, column: 'sex'
{% endhighlight %}
  </li>
  <li>
    <p>`:dirty => true`</p>
  </li>
</ul>

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
