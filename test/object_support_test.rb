require File.expand_path('../test_helper', __FILE__)

class ObjectSupportTest < ActiveSupport::TestCase
  
  test "ensure that symbols stay symbols" do
    assert_same :sym, :sym.to_enum_sym
  end
  
  test "ensure that strings are just converted to symbols, whatever they look like" do
    assert_same :sym, 'sym'.to_enum_sym
    assert_same :OtherSym, 'OtherSym'.to_enum_sym
  end
  
  test "convert custom class to symbol, by providing attr_accessor :name" do
    has_name = Class.new do
      attr_accessor :name
    end
    
    named = has_name.new
    named.name = 'sym'
    
    assert_same :sym, named.to_enum_sym
    
    another_named = has_name.new
    another_named.name = 'Contains Spaces?'
        
    assert_same :contains_spaces, another_named.to_enum_sym
  end
end
