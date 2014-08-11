require 'spec_helper'

describe SimpleEnum::Translation do
  context '.human_enum_name', i18n: true do
    fake_model(:klass) { extend SimpleEnum::Translation }
    subject { klass }

    shared_examples_for 'translating gender' do
      it 'translates :male to "Mr."' do
        expect(subject.human_enum_name(:gender, :male)).to eq 'Mr.'
      end

      it 'translates :female to "Mrs."' do
        expect(subject.human_enum_name(:gender, :female)).to eq 'Mrs.'
      end

      it 'returns empty string when key is missing' do
        expect(subject.human_enum_name(:gender, nil)).to eq ''
      end
    end

    context '{i18n_scope}.enums.{i18n_key}.gender.{key}' do
      before do
        store_translations :en, 'activemodel' => {
          'enums' => {
            'fake_model' => {
              'gender' => { 'male' => 'Mr.', 'female' => 'Mrs.' }
            }
          }
        }
      end

      it_behaves_like 'translating gender'
    end

    context 'enums.{i18n_key}.gender.{key}' do
      before do
        store_translations :en, 'enums' => {
          'fake_model' => {
            'gender' => { 'male' => 'Mr.', 'female' => 'Mrs.' }
          }
        }
      end

      it_behaves_like 'translating gender'
    end

    context 'enums.gender.{key}' do
      before do
        store_translations :en, 'enums' => {
          'gender' => { 'male' => 'Mr.', 'female' => 'Mrs.' }
        }
      end

      it_behaves_like 'translating gender'
    end

    context 'uses :default if available' do
      it 'translates :female to "Frau" using default:' do
        expect(subject.human_enum_name(:gender, :female, default: 'Frau')).to eq 'Frau'
      end
    end

    context 'falls back to titleize' do
      it 'translates using .titleize if no translations found' do
        expect(subject.human_enum_name(:gender, :female)).to eq 'Female'
      end
    end
  end
end
