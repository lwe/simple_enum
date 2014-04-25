require 'spec_helper'

describe SimpleEnum do
  context 'class methods' do
    AnotherEnum = DatabaseSupport.dummy do
      as_enum :gender, [:male, :female]
    end

    subject { AnotherEnum }

    context '.genders' do
      it 'returns a Hash with key => value mappings' do
        enum_hash = { 'male' => 0, 'female' => 1 }
        expect(subject.genders).to eq enum_hash
      end

      it 'accepts an argument and returns the actual value' do
        expect(subject.genders(:male)).to eq 0
        expect(subject.genders(:female)).to eq 1
        expect(subject.genders("female")).to eq 1
        expect(subject.genders(:something_else)).to be_nil
      end
    end

    context '.enum_definitions' do
      it 'contains the definitions' do
        expect(subject.enum_definitions[:gender]).to be_a(Hash)
      end
    end
  end
end
