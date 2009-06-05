require 'test_helper'

# Trap Kernel#warn to check that deprecated warning is added :)
module Kernel
  @@LAST_WARNING = nil
  def warn(msg)
    @@LAST_WARNING = msg
  end
  
  def self.last_warning; @@LAST_WARNING; end
end

class FindersTest < ActiveSupport::TestCase  
  def setup
    reload_db
  end

  test "find all with :gender => :female" do
    girls = Dummy.find :all, :conditions => { :gender_cd => Dummy.genders[:female] }
    
    assert_equal 2, girls.length
  end
  
  test "that inst.values_for_... is deprecated (by trapping Kernel\#warn)" do
    g = Dummy.new
    g.values_for_gender
    
    assert_match /\ADEPRECATION WARNING.*values_for_gender.*genders/, Kernel.last_warning
  end
end