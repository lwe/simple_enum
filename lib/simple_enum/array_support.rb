module SimpleEnum
  module ArraySupport
    
    # Magically convert an array to a hash, has some neat features
    # for active record models and similar.
    #
    # TODO: add more documentation; allow block to be passed to customize key/value pairs
    def to_hash_magic
      v = enum_with_index.to_a unless first.is_a?(ActiveRecord::Base) or first.is_a?(Array)
      v = map { |e| [e, e.id] } if first.is_a?(ActiveRecord::Base)
      v ||= self
      Hash[*v.flatten]
    end
  end
end