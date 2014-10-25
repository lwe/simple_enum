require 'spec_helper'
require 'simple_enum/mongoid'

describe SimpleEnum::Mongoid, mongoid: true do
  fake_mongoid_model(:klass) {
    as_enum :roles, %w{user manager admin}, multi: true
  }

  let(:field) { klass.fields['roles_cd'] }

  context '.as_enum' do
    subject { klass }

    it 'has the roless enum' do
      expect(klass.roless).to be_a(SimpleEnum::Enum)
    end

    it 'creates the :roles_cd field' do
      expect(field).to_not be_nil
      expect(field.type).to eq Object
    end

    context 'field: { type: Array }' do
      fake_mongoid_model(:klass) {
        as_enum :roles, %w{user manager}, field: { type: Array }, multi: true
      }

      it 'creates the :roles_cd field as Array' do
        expect(field).to_not be_nil
        expect(field.type).to eq Array
      end
    end

    context 'field: false' do
      fake_mongoid_model(:klass) {
        as_enum :roles, %w{user manager}, field: false, multi: true
      }

      it 'does not create the field' do
        expect(field).to be_nil
      end
    end
  end
end
