require 'spec_helper'

describe SimpleEnum::Accessors do
  let(:enum) { SimpleEnum::Enum.new(:gender, "male" => 0, "female" => 1) }
  fake_model(:klass)
  let(:object) { klass.new }

  context '.accessor' do
    it 'returns Accessor instance' do
      expect(described_class.accessor(:gender, enum)).to be_a(described_class::Accessor)
    end

    it 'returns a WhinyAccessor instance if accessor: :whiny' do
      expect(described_class.accessor(:gender, enum, accessor: :whiny)).to be_a(described_class::WhinyAccessor)
    end

    it 'sets source to "gender" if source: :gender' do
      expect(described_class.accessor(:gender, enum, source: :gender).source).to eq 'gender'
    end
  end

  context 'Accessor' do
    subject { described_class::Accessor.new(:gender, enum) }

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

    context '#prefix' do
      it 'returns empty string when prefix is nil' do
        expect(described_class::Accessor.new(:gender, enum).prefix).to eq ''
      end

      it 'returns gender_ when prefix is true' do
        expect(described_class::Accessor.new(:gender, enum, nil, true).prefix).to eq 'gender_'
      end

      it 'returns other_ when prefix is "other"' do
        expect(described_class::Accessor.new(:gender, hash, nil, 'other').prefix).to eq 'other_'
      end
    end

    context '#source' do
      it 'returns gender_cd when source is nil' do
        expect(described_class::Accessor.new(:gender, hash, nil).source).to eq 'gender_cd'
      end

      it 'returns "some_column" when source is set to :some_column' do
        expect(described_class::Accessor.new(:gender, hash, :some_column).source).to eq 'some_column'
      end

      it 'returns "gender" when source is set to "gender"' do
        expect(described_class::Accessor.new(:gender, hash, 'gender').source).to eq 'gender'
      end
    end

    context '#plural_scopes' do
      it 'returns false when plural_scopes is nil' do
        expect(described_class::Accessor.new(:gender, enum).plural_scopes).to eq false
      end

      it 'returns true when plural_scopes is true' do
        expect(described_class::Accessor.new(:gender, enum, nil, nil, true).plural_scopes).to eq true
      end
    end

    context '#read' do
      shared_examples_for 'reading an enum' do
        it 'returns nil then gender_cd is nil' do
          expect(subject.read(object)).to be_nil
        end

        it 'returns :male when gender_cd is 0' do
          expect(subject.read(klass.new(0))).to eq :male
        end

        it 'returns :female when gender_cd is 1' do
          expect(subject.read(klass.new(1))).to eq :female
        end
      end

      it_behaves_like 'reading an enum'

      context 'with name == source' do
        subject { described_class::Accessor.new(:gender_cd, enum, :gender_cd) }
        it_behaves_like 'reading an enum'
      end
    end

    context '#write' do
      shared_examples_for 'writing an enum' do
        it 'writes nil to object' do
          object = klass.new(0)
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
          object = klass.new(1)
          expect(subject.write(object, :other)).to be_nil
          expect(object.gender_cd).to be_nil
        end
      end

      it_behaves_like 'writing an enum'

      context 'with name == source' do
        subject { described_class::Accessor.new(:gender_cd, enum, :gender_cd) }
        it_behaves_like 'writing an enum'
      end
    end

    context '#selected?' do
      it 'returns false when gender_cd is nil' do
        expect(subject.selected?(object)).to be_false
        expect(subject.selected?(object, :male)).to be_false
      end

      it 'returns true when gender_cd is != nil' do
        expect(subject.selected?(klass.new(0))).to be_true
        expect(subject.selected?(klass.new(1))).to be_true
      end

      it 'returns true when gender_cd is 0 and :male is passed' do
        expect(subject.selected?(klass.new(0), :male)).to be_true
      end

      it 'returns false when gender_cd is 0 and :female is passed' do
        expect(subject.selected?(klass.new(0), :female)).to be_false
      end

      it 'returns false when gender_cd is 1 and :other is passed' do
        expect(subject.selected?(klass.new(0), :other)).to be_false
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
    subject { described_class::IgnoreAccessor.new(:gender, enum) }

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
    subject { described_class::WhinyAccessor.new(:gender, enum) }

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
