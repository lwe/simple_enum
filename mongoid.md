---
layout: default
title: "Using simple_enum with Mongoid - simple_enum"
excerpt: "Guide for integrating simple_enum with Mongoid."
---

# Using simple_enum with Mongoid

Adding an enum field to a Mongoid document using simple_enum requires an
additional step and a slightly adopted as_enum method which works with mongoid.

<ol>
  <li>
    Load mongoid support in an initalizer:
{% highlight ruby %}
require 'simple_enum/mongoid'
# NOTE TO SELF: use autoload in simple_enum, so we can skip this
# step in the future...
{% endhighlight %}
  </li>
  <li>
    Include Mongoid module and add <code>as_enum</code> to your document, a field named <code>gender_cd</code>
    is added automatically by simple_enum:
{% highlight ruby %}
class User
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :gender, :female => 1, :male => 0
end
{% endhighlight %}
  </li>
  <li>
    Wohooo, done!
{% highlight ruby %}
user = User.new(:gender => 'male')
user.male?     # => true
{% endhighlight %}
  </li>
</ol>
