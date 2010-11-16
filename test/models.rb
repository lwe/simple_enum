class Dummy < ActiveRecord::Base
  as_enum :gender, [:male, :female]
  as_enum :word, { :alpha => 'alpha', :beta => 'beta', :gamma => 'gamma'}
  as_enum :didum, [ :foo, :bar, :foobar ], :column => 'other'  
end

class Gender < ActiveRecord::Base
end

# Used to test STI stuff
class SpecificDummy < Dummy
  set_table_name 'dummies'
end
