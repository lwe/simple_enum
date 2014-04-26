require 'spec_helper'

describe SimpleEnum::Attribute do
  context 'attributes' do
    SomeEnum = DatabaseSupport.dummy do
      as_enum :gender, [:male, :female], with: [:query, :bang]
    end

    subject { SomeEnum.new }

    context '.genders' do
      it 'returns a SimpleEnum::Enum' do
        expect(SomeEnum.genders).to be_a(SimpleEnum::Enum)
      end
    end

    context '#gender & #gender=' do
      it 'gender should be nil when not set' do
        expect(SomeEnum.new.gender).to be_nil
      end

      it 'sets gender to :male via constructor' do
        expect(SomeEnum.new(gender: :male).gender).to eq :male
      end

      it 'when setting #gender= it sets actually #gender_cd as well' do
        subject.gender = :female
        expect(subject.gender).to eq :female
        expect(subject.gender_cd).to eq 1
      end

      it 'can set #gender using the actual value' do
        subject.gender = 1
        expect(subject.gender).to eq :female
      end

      it 'can set #gender using a String' do
        subject.gender = "female"
        expect(subject.gender).to eq :female
      end

      it 'raises an ArgumentError if invalid value is passed' do
        pending
        expect { subject.gender = :something }.to raise_error(ArgumentError)
      end
    end

    shared_examples_for 'question mark methods' do |male, female|
      it "#{male ? 'is' : 'is not'} #male?" do
        result = male ? be_true : be_false
        expect(subject.male?).to result
      end

      it "#{female ? 'is' : 'is not'} #female?" do
        result = female ? be_true : be_false
        expect(subject.female?).to result
      end

      if male || female
        it 'returns true for #gender?' do
          expect(subject.gender?).to be_true
        end

        it "returns #{male ? 'true' : 'false'} for #gender?(:male)" do
          expect(subject.gender?(:male)).to eq male
        end

        it "returns #{female ? 'true' : 'false'} for #gender?(:female)" do
          expect(subject.gender?(:female)).to eq female
        end
      else
        it 'returns false for #gender?' do
          expect(subject.gender?).to be_false
        end
      end

      it 'returns false for #gender?(:something)' do
        expect(subject.gender?(:something)).to be_false
      end
    end

    context '#gender?, #male? & #female?' do
      context 'when gender is nil' do
        subject { SomeEnum.new }
        it_behaves_like "question mark methods", false, false
      end

      context 'when gender is :male' do
        subject { SomeEnum.new(gender: :male) }
        it_behaves_like "question mark methods", true, false
      end

      context 'when gender is :female' do
        subject { SomeEnum.new(gender: :female) }
        it_behaves_like "question mark methods", false, true
      end
    end

    shared_examples_for 'sets gender to' do |key, value|
      it "sets gender to #{key.inspect}" do
        expect(subject.gender).to eq key
      end

      it "sets gender_cd to #{value}" do
        expect(subject.gender_cd).to eq value
      end
    end

    context '#male!' do
      before { subject.male! }
      it_behaves_like 'sets gender to', :male, 0
    end

    context '#female!' do
      before { subject.female! }
      it_behaves_like 'sets gender to', :female, 1
    end
  end
end
