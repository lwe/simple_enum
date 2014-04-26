require 'spec_helper'

describe SimpleEnum::Enum do
  FakeObject = Struct.new(:gender_cd)

  let(:hash) do
    { male: 0, female: 1 }
  end

  let(:object) { FakeObject.new }

  subject { described_class.new(:gender, hash) }

  context '#initialize' do
    shared_examples_for "creates an Enum instance" do
      it 'is an Enum' do
        expect(subject).to be_a(described_class)
      end

      it 'sets name to "gender"' do
        expect(subject.name).to eq 'gender'
      end

      it 'sets source to "src"' do
        expect(subject.source).to eq 'src'
      end

      it 'sets prefix to "pfx_"' do
        expect(subject.prefix).to eq 'pfx_'
      end

      it 'sets hash to { "male" => 0, "female" => 1 }' do
        expect(subject.hash.keys).to eq %w{male female}
        expect(subject.hash.values).to eq [0, 1]
      end
    end

    context 'with Array' do
      subject { described_class.new(:gender, %w{male female}, source: :src, prefix: :pfx) }
      it_behaves_like 'creates an Enum instance'
    end

    context 'with Hash' do
      subject { described_class.new(:gender, hash, source: :src, prefix: :pfx) }
      it_behaves_like 'creates an Enum instance'
    end
  end

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
    subject { described_class.new(:gender, hash).hash }

    it 'returns a frozen hash that was set in the constructor' do
      expect(subject).to be_a(Hash)
      expect(subject.keys).to eq %w{male female}
      expect(subject.values).to eq [0, 1]
    end

    it 'is frozen' do
      expect(subject).to be_frozen
    end
  end

  context '#prefix' do
    it 'returns empty string when prefix is nil' do
      expect(described_class.new(:gender, hash).prefix).to eq ''
    end

    it 'returns gender_ when prefix is true' do
      expect(described_class.new(:gender, hash, prefix: true).prefix).to eq 'gender_'
    end

    it 'returns other_ when prefix is "other"' do
      expect(described_class.new(:gender, hash, prefix: 'other').prefix).to eq 'other_'
    end
  end

  context '#source' do
    it 'returns gender_cd when source is nil' do
      expect(described_class.new(:gender, hash).source).to eq 'gender_cd'
    end

    it 'returns "some_column" when source is set to :some_column' do
      expect(described_class.new(:gender, hash, source: :some_column).source).to eq 'some_column'
    end

    it 'returns "gender" when source is set to "gender"' do
      expect(described_class.new(:gender, hash, source: 'gender').source).to eq 'gender'
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
      expect(subject.value(:inexistent)).to be_nil
      expect(subject[:inexistent]).to be_nil
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

  context '#include?' do
    it 'returns true by string' do
      expect(subject.include?('male')).to be_true
    end

    it 'returns true by symbol' do
      expect(subject.include?(:female)).to be_true
    end

    it 'returns true by checking actual value' do
      expect(subject.include?(1)).to be_true
    end

    it 'returns false when neither in keys nor values' do
      expect(subject.include?(:other)).to be_false
      expect(subject.include?(2)).to be_false
    end
  end
end
