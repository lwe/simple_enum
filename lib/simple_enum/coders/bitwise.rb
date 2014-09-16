module SimpleEnum
  module Coders
    class Bitwise
      def self.load(data)
        n = data.to_i
        (0..Math.log2(n).floor).reject do |i|
          (n & (1 << i)).zero?
        end
      rescue FloatDomainError, Math::DomainError
        []
      end

      def self.dump(array)
        array.map do |i|
          1 << i
        end.reduce(&:+)
      end
    end
  end
end