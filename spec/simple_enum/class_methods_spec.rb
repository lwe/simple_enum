require 'spec_helper'

describe SimpleEnum do
  context 'class methods' do
    AnotherEnum = DatabaseSupport.dummy do
      as_enum :gender, [:male, :female]
    end

    subject { AnotherEnum }

    context '.genders' do
      it 'returns a SimpleEnum::Enum' do
        expect(subject.genders).to be_a(SimpleEnum::Enum)
      end
    end
  end
end
