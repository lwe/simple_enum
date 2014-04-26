require 'spec_helper'

describe SimpleEnum::Accessors do
  OtherFakeObject = Struct.new(:gender_cd)

  let(:hash) do
    { female: 1, male: 0 }
  end

  let(:object) { OtherFakeObject.new }

  let(:enum) { SimpleEnum::Enum.new(:gender, hash) }
  let(:direct_enum) { SimpleEnum::Enum.new(:gender_cd, hash, :gender_cd) }

  context '.accessor' do
    it 'returns Accessor instance' do
      expect(described_class.accessor(enum)).to be_a(described_class::Accessor)
    end

    it 'returns a WhinyWriteAccessor instance if accessor: :whiny' do
      expect(described_class.accessor(enum, accessor: :whiny)).to be_a(described_class::WhinyAccessor)
    end
  end

  context 'Accessor' do
    subject { described_class::Accessor.new(enum) }

    context '#read' do
      shared_examples_for 'reading an enum' do
        it 'returns nil then gender_cd is nil' do
          expect(subject.read(object)).to be_nil
        end

        it 'returns :male when gender_cd is 0' do
          expect(subject.read(OtherFakeObject.new(0))).to eq :male
        end

        it 'returns :female when gender_cd is 1' do
          expect(subject.read(OtherFakeObject.new(1))).to eq :female
        end
      end

      it_behaves_like 'reading an enum'

      context 'with name == source' do
        subject { described_class::Accessor.new(direct_enum) }
        it_behaves_like 'reading an enum'
      end
    end

    context '#write' do
      shared_examples_for 'writing an enum' do
        it 'writes nil to object' do
          object = OtherFakeObject.new(0)
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
          object = OtherFakeObject.new(1)
          expect(subject.write(object, :other)).to be_nil
          expect(object.gender_cd).to be_nil
        end
      end

      it_behaves_like 'writing an enum'

      context 'with name == source' do
        subject { described_class::Accessor.new(direct_enum) }
        it_behaves_like 'writing an enum'
      end
    end

    context '#selected?' do
      it 'returns false when gender_cd is nil' do
        expect(subject.selected?(object)).to be_false
        expect(subject.selected?(object, :male)).to be_false
      end

      it 'returns true when gender_cd is != nil' do
        expect(subject.selected?(OtherFakeObject.new(0))).to be_true
        expect(subject.selected?(OtherFakeObject.new(1))).to be_true
      end

      it 'returns true when gender_cd is 0 and :male is passed' do
        expect(subject.selected?(OtherFakeObject.new(0), :male)).to be_true
      end

      it 'returns false when gender_cd is 0 and :female is passed' do
        expect(subject.selected?(OtherFakeObject.new(0), :female)).to be_false
      end

      it 'returns false when gender_cd is 1 and :other is passed' do
        expect(subject.selected?(OtherFakeObject.new(0), :other)).to be_false
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

  context 'IgnoreAccessor' do
    subject { described_class::IgnoreAccessor.new(enum) }

    it 'sets gender_cd to 0 with symbol' do
      expect(subject.write(object, :male)).to_not be_false
      expect(object.gender_cd).to eq 0
    end

    it 'sets gender_cd to 1 via value (1)' do
      expect(subject.write(object, 1)).to_not be_false
      expect(object.gender_cd).to eq 1
    end

    it 'sets gender_cd to nil' do
      expect(subject.write(object, nil)).to be_false
      expect(object.gender_cd).to be_nil
    end

    it 'keeps existing value when unknown value is passed' do
      object.gender_cd = 1
      expect(subject.write(object, :other)).to be_false
      expect(object.gender_cd).to eq 1
    end
  end

  context 'WhinyAccessor' do
    subject { described_class::WhinyAccessor.new(enum) }

    it 'raises no error when setting existing key' do
      expect { subject.write(object, :male) }.to_not raise_error
      expect(object.gender_cd).to eq 0
    end

    it 'raises no error when setting with existing value' do
      expect { subject.write(object, 1) }.to_not raise_error
      expect(object.gender_cd).to eq 1
    end

    it 'raises no error when setting to nil' do
      expect { subject.write(object, nil) }.to_not raise_error
      expect(object.gender_cd).to be_nil
    end

    it 'raises ArgumentError when setting invalid key' do
      expect { subject.write(object, :other) }.to raise_error(ArgumentError)
    end
  end
end
