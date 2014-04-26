require 'spec_helper'

describe SimpleEnum do
  context '.as_enum' do
    context 'with prefix: true' do
      DefaultWithPrefix = DatabaseSupport.dummy do
        as_enum :gender, [:male, :female], prefix: true
      end

      subject { DefaultWithPrefix.new }

      it 'adds prefixed scopes (gender_male & gender_female)' do
        expect(DefaultWithPrefix).to respond_to(:gender_male)
        expect(DefaultWithPrefix).to respond_to(:gender_female)
      end

      it 'adds prefixed question methods (gender_male? & gender_female?)' do
        expect(subject).to respond_to(:gender_male?)
        expect(subject).to respond_to(:gender_female?)
      end

      it 'adds prefixed bang methods (gender_male! & gender_female!)' do
        expect(subject).to respond_to(:gender_male!)
        expect(subject).to respond_to(:gender_female!)
      end
    end

    context 'with prefix: "geschlecht"' do
      GeschlechtWithPrefix = DatabaseSupport.dummy do
        as_enum :gender, [:male, :female], prefix: 'geschlecht'
      end

      subject { GeschlechtWithPrefix.new }

      it 'adds prefixed scopes (geschlecht_male & geschlecht_female)' do
        expect(GeschlechtWithPrefix).to respond_to(:geschlecht_male)
        expect(GeschlechtWithPrefix).to respond_to(:geschlecht_female)
      end

      it 'adds prefixed question methods (geschlecht_male? & geschlecht_female?)' do
        expect(subject).to respond_to(:geschlecht_male?)
        expect(subject).to respond_to(:geschlecht_female?)
      end

      it 'adds prefixed bang methods (geschlecht_male! & geschlecht_female!)' do
        expect(subject).to respond_to(:geschlecht_male!)
        expect(subject).to respond_to(:geschlecht_female!)
      end
    end

    context 'with slim: true' do
      SlimAndLight = DatabaseSupport.dummy do
        as_enum :gender, [:male, :female], with: []
      end

      subject { SlimAndLight.new }

      it 'does not have #male? and #female?' do
        expect(subject).to_not respond_to(:male?)
        expect(subject).to_not respond_to(:female?)
      end

      it 'does not have #male! and #female!' do
        expect(subject).to_not respond_to(:male!)
        expect(subject).to_not respond_to(:female!)
      end
    end

    context 'with strings: true' do
      it 'should treat Arrays as strings, not integers'
    end
  end
end