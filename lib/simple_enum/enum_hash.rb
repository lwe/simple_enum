module SimpleEnum
  
  # Internal hash class, used to handle the enumerations et al.
  # Works like to original +Hash+ class, but with some added value,
  # like access to 
  #
  # 
  class EnumHash < ::ActiveSupport::OrderedHash
    def initialize(args = [])
      super()
      
      @reverse_sym_lookup = {}
      @sym_value_lookup = {}

      if args.is_a?(Hash)
        args.each { |k,v| set_value_for_reverse_lookup(k, v) }
      else
        ary = args.each_with_index.to_a unless args.first.is_a?(ActiveRecord::Base) or args.first.is_a?(Array)
        ary = args.map { |e| [e, e.id] } if args.first.is_a?(ActiveRecord::Base)
        ary ||= args
        ary.each { |e| set_value_for_reverse_lookup(e[0], e[1]) }
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
    
    private
      def set_value_for_reverse_lookup(key, value)
        sym = key.to_enum_sym
        self[key] = value
        @reverse_sym_lookup[sym] = key
        @sym_value_lookup[sym] = value
      end    
  end
end