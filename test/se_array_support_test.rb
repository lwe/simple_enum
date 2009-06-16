class SeArraySupportTest < ActiveSupport::TestCase
  test "that when simple array is merge to hash, array values are the keys and indicies are values" do
    a = [:a, :b, :c, :d]
    h = a.to_hash_magic
    
    assert_same 0, h[:a]
    assert_same 1, h[:b]
    assert_same 2, h[:c]
    assert_same 3, h[:d]
  end
  
  test "that an already correct looking array is converted to a hash" do
    a = [[:a, 5], [:b, 10]]
    h = a.to_hash_magic
    
    assert_same 5, h[:a]
    assert_same 10, h[:b]
  end
  
  test "that an array of ActiveRecords are converted to <obj> => obj.id" do
    reload_db :genders => true # reload db
    a = Gender.find(:all, :order => :id)
    
    male = Gender.find(0)
    female = Gender.find(1)
    
    h = a.to_hash_magic
    
    assert_same 0, h[male]
    assert_same 1, h[female]
  end
end