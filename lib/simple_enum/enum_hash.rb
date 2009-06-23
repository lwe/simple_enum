module SimpleEnum
  
  # Internal hash class, used to handle the enumerations et al.
  # Works like to original +Hash+ class, but with some added value,
  # like access to 
  #
  # 
  class EnumHash < ::Hash
    def initialize(hsh)
      hsh = hsh.to_hash_magic unless hsh.is_a?(Hash)
      
      @reverse_sym_lookup = {}
      @sym_value_lookup = {}
      
      hsh.each do |k,v|
        sym = k.to_enum_sym
        self[k] = v
        @reverse_sym_lookup[sym] = k
        @sym_value_lookup[sym] = v
      end
    end
    
    def default(k = nil)
      @sym_value_lookup[k.to_enum_sym] if k
    end
        
    def method_missing(symbol, *args)
      if @sym_value_lookup.has_key?(symbol.to_enum_sym)
        return @reverse_sym_lookup[symbol.to_enum_sym] if args.first
        self[symbol]
      else
        super
      end
    end
  end
end