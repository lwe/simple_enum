require 'test_helper'

class ClassMethodsTest < ActiveSupport::TestCase  
  def setup
    reload_db
  end

  test "that Klass.genders[:sym] == Klass.genders(:sym)" do
    assert_equal 0, Dummy.genders(:male)
    assert_equal Dummy.genders(:male), Dummy.genders[:male]
    assert_nil Dummy.genders(:inexistent)
    assert_nil Dummy.genders[:inexistent]
  end
  
  test "that inst.values_for_... is deprecated (by trapping Kernel\#warn)" do
    g = Dummy.new
    g.values_for_gender
    
    assert_match /\ADEPRECATION WARNING.*values_for_gender.*genders/, Kernel.last_warning
  end
end