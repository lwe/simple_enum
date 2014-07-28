require 'spec_helper'

describe SimpleEnum::ViewHelpers, i18n: true do
  let(:helper) {
    Class.new do
      include SimpleEnum::ViewHelpers
    end.new
  }

  fake_model(:klass) do
    as_enum :gender, %w{male female}
  end

  context '#enum_option_pairs' do
    subject { helper.enum_option_pairs(klass, :gender) }

    it 'returns an Array of Arrays when a model instance is passed in' do
      expect(helper.enum_option_pairs(klass.new, :gender)).to eq [
        ["Male", "male"], ["Female", "female"]
      ]
    end

    it 'returns an Array of Array when the class is passed in' do
      expect(subject).to eq [
        ["Male", "male"], ["Female", "female"]
      ]
    end

    it 'returns the value instead of the key when last argument is set to true' do
      expect(helper.enum_option_pairs(klass, :gender, true)).to eq [
        ["Male", 0], ["Female", 1]
      ]
    end

    context 'with translation in enums.{...}' do
      before {
        store_translations :en, 'enums' => {
          'gender' => { 'male' => 'Mr.', 'female' => 'Mrs.' }
        }
      }

      it 'returns the translation as defined in the translations' do
        expect(subject).to eq [
          ["Mr.", "male"], ["Mrs.", "female"]
        ]
      end
    end

    context 'with .human_enum_name' do
      before {
        expect(klass).to receive(:human_enum_name).with(:gender, "male") { "Mr." }
        expect(klass).to receive(:human_enum_name).with(:gender, "female") { "Mrs." }
      }

      it 'returns the translation as given #human_enum_name' do
        expect(subject).to eq [
          ["Mr.", "male"], ["Mrs.", "female"]
        ]
      end
    end
  end

  context '#translate_enum' do
    let(:fake_object) { klass.new }
    it "translates with object scope" do
      fake_object.gender = :male
      expect(klass).to receive(:human_enum_name).with(:gender, :male) { "Mr." }
      expect(helper.translate_enum(fake_object, :gender)).to eq "Mr."
    end
  end
end
