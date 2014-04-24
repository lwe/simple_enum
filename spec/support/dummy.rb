class Dummy < ActiveRecord::Base
  as_enum :gender, [:male, :female]
  as_enum :word, { alpha: 'alpha', beta: 'beta', gamma: 'gamma'}
  as_enum :didum, [ :foo, :bar, :foobar ], column: 'other'
  as_enum :role, [:admin, :member, :anon], strings: true
  as_enum :numeric, [:"100", :"3.14"], strings: true
  as_enum :nilish, [:nil], strings: true
  as_enum :style, [:vintage, :modern], scopes: true
end
