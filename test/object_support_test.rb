class ObjectSupportTest < MiniTest::Unit::TestCase
  
  def test_that_symbols_stay_symbols
    assert_same :sym, :sym.to_enum_sym
  end
  
  def test_that_strings_are_just_converted_to_symbols
    assert_same :sym, 'sym'.to_enum_sym
    assert_same :OtherSym, 'OtherSym'.to_enum_sym
  end
  
  def test_conversion_of_custom_class_to_symbol
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