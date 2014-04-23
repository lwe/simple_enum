module SimpleEnum

  # Internal hash class, used to handle the enumerations et al.
  # Works like to original +Hash+ class, but with some added value,
  # like access to
  #
  class EnumHash < ::ActiveSupport::OrderedHash

    # Converts an entity to a symbol, uses to_enum_sym, if possible.
    def self.symbolize(sym)
      return sym.to_enum_sym if sym.respond_to?(:to_enum_sym)
      return sym.to_sym if sym.respond_to?(:to_sym)
      return sym.name.to_s.parameterize('_').to_sym if sym.respond_to?(:name)
      sym.to_param.to_sym if sym.present? && sym.respond_to?(:to_param)
      sym unless sym.blank?
    end

    def initialize(args = [], strings = false)
      super()

      @reverse_sym_lookup = {}
      @sym_value_lookup = {}

      if args.is_a?(Hash)
        args.each { |k,v| set_value_for_reverse_lookup(k, v) }
      else
        ary = args.send(args.respond_to?(:enum_with_index) ? :enum_with_index : :each_with_index).to_a unless args.first.respond_to?(:map)
        ary = args.map { |e| [e, e.id] } if args.first.respond_to?(:map) && !args.first.is_a?(Array)
        ary ||= args
        ary.each { |e| set_value_for_reverse_lookup(e[0], strings ? e[0].to_s : e[1]) }
      end

      @stringified_keys = keys.map(&:to_s)

      freeze
    end

    def contains?(value)
      @stringified_keys.include?(value.to_s) || values.include?(value)
    end

    def default(k = nil)
      @sym_value_lookup[EnumHash.symbolize(k)] if k
    end

    def method_missing(symbol, *args)
      sym = EnumHash.symbolize(symbol)
      if @sym_value_lookup.has_key?(sym)
        return @reverse_sym_lookup[sym] if args.first
        self[symbol]
      else
        super
      end
    end

    private
      def set_value_for_reverse_lookup(key, value)
        sym = EnumHash.symbolize(key)
        self[key] = value
        @reverse_sym_lookup[sym] = key
        @sym_value_lookup[sym] = value
      end
  end
end
