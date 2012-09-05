---
layout: default
title: "simple_enum: enum fields for ruby"
---

## Quicklinks

- [Configuring simple_enum](#Configuring+simple_enum)
- [Rails integration](#Using+simple_enum+with+Rails)
- [Mongoid usage](#Using+simple_enum+with+Mongoid)

# Getting started

Starting with simple_enum is as easy as adding this line to your application's Gemfile:

{% highlight ruby %}
gem 'simple_enum'
{% endhighlight %}

And then execute `bundle` or install it yourself: `gem install simple_enum`.

# Using simple_enum with Rails

Assuming simple_enum has been added to your Gemfile and you are using ActiveRecord, simple_enum
works out of to box.

1. Add a _code_ (cd) column to your table using migrations, like:
```ruby
add_column :people, :gender_cd, :integer
```
2. Add `as_enum` in your model:
```ruby
class Person < ActiveRecord::Base
  as_enum :gender, %w{female male}
end
```

# Using simple_enum with Mongoid

# Using simple_enum with Ruby (plain old ruby)

# Configuring simple_enum
