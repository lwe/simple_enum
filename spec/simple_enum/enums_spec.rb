require 'spec_helper'

describe SimpleEnum::Enums do
  let(:hash) do
    { "male" => 0, "female" => 1 }
  end

  fake_model(:klass)
  let(:object) { klass.new }

  context '.enum' do
    it 'returns Enum instance' do
      expect(described_class.enum(:gender, hash)).to be_a(described_class::Enum)
    end

    it 'returns a MultiEnum instance if multiple: true)' do
      expect(described_class.enum(:gender, hash, multiple: true)).to be_a(described_class::MultiEnum)
    end
  end

  context 'Enum' do
    subject { described_class::Enum.new(:gender, hash) }

    context '#name' do
      it 'returns the enum name as string' do
        expect(subject.name).to eq 'gender'
      end
    end

    context '#to_s' do
      it 'returns the name' do
        expect(subject.to_s).to eq 'gender'
      end
    end

    context '#hash' do
      it 'returns hash that was set in the constructor' do
        expect(subject.hash).to be_a(Hash)
        expect(subject.hash.keys).to eq %w{male female}
        expect(subject.hash.values).to eq [0, 1]
      end
    end

    context '#keys' do
      it 'returns the keys in the order added' do
        expect(subject.keys).to eq %w{male female}
      end
    end

    context '#each_pair (aliased to #each)' do
      it 'yields twice with #each_pair' do
        expect { |b| subject.each_pair(&b) }.to yield_control.exactly(2).times
      end

      it 'yields twice with #each' do
        expect { |b| subject.each(&b) }.to yield_control.exactly(2).times
      end
    end

    context '#value (aliased to #[])' do
      it 'looks up by string' do
        expect(subject.value('male')).to eq 0
        expect(subject['male']).to eq 0
      end

      it 'looks up by symbol' do
        expect(subject.value(:female)).to eq 1
        expect(subject[:female]).to eq 1
      end

      it 'looks up by value' do
        expect(subject.value(0)).to be 0
        expect(subject[0]).to be 0
      end

      it 'returns nil when key is not found' do
        expect(subject.value(:other)).to be_nil
        expect(subject[:other]).to be_nil
      end
    end

    context '#key' do
      it 'returns symbolized key for supplied value' do
        expect(subject.key(0)).to eq :male
        expect(subject.key(1)).to eq :female
      end

      it 'returns nil if value is not found' do
        expect(subject.key(12)).to be_nil
      end
    end

    context '#match?' do
      it 'returns false when value is nil' do
        expect(subject.match?(:male, nil)).to be_falsey
      end

      it 'returns true when value is 0 and :male is passed' do
        expect(subject.match?(:male, 0)).to be_truthy
      end

      it 'returns false when value is 0 and :female is passed' do
        expect(subject.match?(:female, 0)).to be_falsey
      end

      it 'returns false when value is 1 and :other is passed' do
        expect(subject.match?(:other, 0)).to be_falsey
      end
    end

    context '#include?' do
      it 'returns true by string' do
        expect(subject.include?('male')).to be_truthy
      end

      it 'returns true by symbol' do
        expect(subject.include?(:female)).to be_truthy
      end

      it 'returns true by checking actual value' do
        expect(subject.include?(1)).to be_truthy
      end

      it 'returns false when neither in keys nor values' do
        expect(subject.include?(:other)).to be_falsey
        expect(subject.include?(2)).to be_falsey
      end
    end

    context '#values_at' do
      it 'fetches multiple values by string' do
        expect(subject.values_at("male", "female")).to eq [0, 1]
      end

      it 'fetches multiple values by symbol' do
        expect(subject.values_at(:male)).to eq [0]
      end
    end
  end
end
