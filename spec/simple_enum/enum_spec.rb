require 'spec_helper'

describe SimpleEnum::Enum do
  FakeObject = Struct.new(:gender_cd)

  let(:hash) do
    { female: 1, male: 0 }
  end

  let(:object) { FakeObject.new }

  subject { described_class.new(:gender, hash) }

  context '#name' do
    it 'returns the enum name as string' do
      expect(described_class.new(:gender, {}).name).to eq 'gender'
    end
  end

  context '#hash' do
    subject { described_class.new(:gender, hash).hash }
    it 'returns the hash that was set in the constructor, but with indifferent access' do
      expect(subject).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(subject.keys).to eq %w{female male}
      expect(subject.values).to eq [1, 0]
    end
  end

  context '#prefix' do
    it 'returns empty string when prefix is nil' do
      expect(described_class.new(:gender, {}, nil, nil).prefix).to eq ''
    end

    it 'returns gender_ when prefix is true' do
      expect(described_class.new(:gender, {}, nil, true).prefix).to eq 'gender_'
    end

    it 'returns other_ when prefix is "other"' do
      expect(described_class.new(:gender, {}, nil, 'other').prefix).to eq 'other_'
    end
  end

  context '#source' do
    it 'returns gender_cd when source is nil' do
      expect(described_class.new(:gender, {}, nil, nil).source).to eq 'gender_cd'
    end

    it 'returns "some_column" when source is set to :some_column' do
      expect(described_class.new(:gender, {}, :some_column, nil).source).to eq 'some_column'
    end

    it 'returns "gender" when source is set to "gender"' do
      expect(described_class.new(:gender, {}, 'gender', nil).source).to eq 'gender'
    end
  end

  context '#[]' do
    subject { described_class.new(:gender, hash) }

    it 'looks up by string' do
      expect(subject['male']).to eq 0
    end

    it 'looks up by symbol' do
      expect(subject[:female]).to eq 1
    end

    it 'returns nil when key is not found' do
      expect(subject[:inexistent]).to be_nil
    end
  end

  context '#read' do
    shared_examples_for 'reading an enum' do
      it 'returns nil then gender_cd is nil' do
        expect(subject.read(object)).to be_nil
      end

      it 'returns :male when gender_cd is 0' do
        expect(subject.read(FakeObject.new(0))).to eq :male
      end

      it 'returns :female when gender_cd is 1' do
        expect(subject.read(FakeObject.new(1))).to eq :female
      end
    end

    it_behaves_like 'reading an enum'

    context 'with name == source' do
      subject { described_class.new(:gender_cd, hash, :gender_cd) }
      it_behaves_like 'reading an enum'
    end
  end

  context '#write' do
    shared_examples_for 'writing an enum' do
      it 'writes nil to object' do
        object = FakeObject.new(0)
        expect(subject.write(object, nil)).to be_nil
        expect(object.gender_cd).to be_nil
      end

      it 'writes 1 to object with :female' do
        expect(subject.write(object, :female)).to eq :female
        expect(object.gender_cd).to eq 1
      end

      it 'writes 0 to object with "male"' do
        expect(subject.write(object, 'male')).to eq 'male'
        expect(object.gender_cd).to eq 0
      end

      it 'writes 1 to object with 1' do
        expect(subject.write(object, 1)).to eq 1
        expect(object.gender_cd).to eq 1
      end

      it 'writes nil to object with :other' do
        object = FakeObject.new(1)
        expect(subject.write(object, :other)).to be_nil
        expect(object.gender_cd).to be_nil
      end
    end

    it_behaves_like 'writing an enum'

    context 'with name == source' do
      it_behaves_like 'writing an enum'
    end
  end

  context '#selected?' do
    it 'returns false when gender_cd is nil' do
      expect(subject.selected?(object)).to be_false
      expect(subject.selected?(object, :male)).to be_false
    end

    it 'returns true when gender_cd is != nil' do
      expect(subject.selected?(FakeObject.new(0))).to be_true
      expect(subject.selected?(FakeObject.new(1))).to be_true
    end

    it 'returns true when gender_cd is 0 and :male is passed' do
      expect(subject.selected?(FakeObject.new(0), :male)).to be_true
    end

    it 'returns false when gender_cd is 0 and :female is passed' do
      expect(subject.selected?(FakeObject.new(0), :female)).to be_false
    end

    it 'returns false when gender_cd is 1 and :other is passed' do
      expect(subject.selected?(FakeObject.new(0), :other)).to be_false
    end
  end

  context '#changed?' do
    it 'delegates to attribute_changed?' do
      expect(object).to receive(:attribute_changed?).with('gender_cd') { true }
      expect(subject.changed?(object)).to be_true
    end
  end

  context 'was' do
    it 'delegates to attribute_was and resolves symbol' do
      expect(object).to receive(:attribute_was).with('gender_cd') { 1 }
      expect(subject.was(object)).to eq :female
    end
  end
end
