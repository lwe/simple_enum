require 'spec_helper'

describe SimpleEnum do
  context '.as_enum' do
    context 'with prefix: true' do
      fake_active_record(:klass_with_prefix) {
        as_enum :gender, [:male, :female], prefix: true
      }

      subject { klass_with_prefix.new }

      it 'adds prefixed scopes (gender_male & gender_female)' do
        expect(klass_with_prefix).to respond_to(:gender_male)
        expect(klass_with_prefix).to respond_to(:gender_female)
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
      fake_active_record(:klass_with_prefix) {
        as_enum :gender, [:male, :female], prefix: 'geschlecht'
      }

      subject { klass_with_prefix.new }

      it 'adds prefixed scopes (geschlecht_male & geschlecht_female)' do
        expect(klass_with_prefix).to respond_to(:geschlecht_male)
        expect(klass_with_prefix).to respond_to(:geschlecht_female)
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
      fake_model(:klass_without_features) {
        as_enum :gender, [:male, :female], with: []
      }

      subject { klass_without_features.new }

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
