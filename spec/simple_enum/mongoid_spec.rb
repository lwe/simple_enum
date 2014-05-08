require 'spec_helper'
require 'simple_enum/mongoid'

describe SimpleEnum::Mongoid, mongoid: true do
  fake_mongoid_model(:klass) {
    as_enum :gender, %w{male female}
  }

  let(:field) { klass.fields['gender_cd'] }

  context '.as_enum' do
    subject { klass }

    it 'has the genders enum' do
      expect(klass.genders).to be_a(SimpleEnum::Enum)
    end

    it 'creates the :gender_cd field' do
      expect(field).to_not be_nil
      expect(field.type).to eq Object
    end

    context 'field: { type: Integer }' do
      fake_mongoid_model(:klass) {
        as_enum :gender, %w{male female}, field: { type: Integer }
      }

      it 'creates the :gender_cd field as Integer' do
        expect(field).to_not be_nil
        expect(field.type).to eq Integer
      end
    end

    context 'field: false' do
      fake_mongoid_model(:klass) {
        as_enum :gender, %w{male female}, field: false
      }

      it 'does not create the field' do
        expect(field).to be_nil
      end
    end
  end
end
