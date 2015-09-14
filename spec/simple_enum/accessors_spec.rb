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

  context '.register_accessor' do
    let(:accessor) { Class.new { def initialize(*args); end } }
    subject { described_class.accessor(:gender, "enum", accessor: :would_be) }

    before { SimpleEnum.register_accessor :would_be, accessor }
    after { SimpleEnum::Accessors::ACCESSORS.delete(:would_be) }

    it 'adds accessor to ACCESSORS' do
      expect(SimpleEnum::Accessors::ACCESSORS[:would_be]).to eq accessor
    end

    it 'allows to create an instance of our WouldBeAccessor' do
      expect(subject).to be_a accessor
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
        expect(subject.selected?(object)).to be_falsey
        expect(subject.selected?(object, :male)).to be_falsey
      end

      it 'returns true when gender_cd is != nil' do
        expect(subject.selected?(klass.new(0))).to be_truthy
        expect(subject.selected?(klass.new(1))).to be_truthy
      end

      it 'returns true when gender_cd is 0 and :male is passed' do
        expect(subject.selected?(klass.new(0), :male)).to be_truthy
      end

      it 'returns false when gender_cd is 0 and :female is passed' do
        expect(subject.selected?(klass.new(0), :female)).to be_falsey
      end

      it 'returns false when gender_cd is 1 and :other is passed' do
        expect(subject.selected?(klass.new(0), :other)).to be_falsey
      end
    end

    context '#changed?' do
      it 'delegates to attribute_changed?' do
        expect(object).to receive(:attribute_changed?).with('gender_cd') { true }
        expect(subject.changed?(object)).to be_truthy
      end
    end

    context '#was' do
      let(:changes) do
        { 'gender_cd' => 1 }
      end

      it 'delegates to changed_attributes and resolves symbol' do
        expect(object).to receive(:changed_attributes) { changes }
        expect(subject.was(object)).to eq :female
      end
    end
  end

  context 'dirty attributes on ActiveModel', active_record: true do
    fake_active_record(:klass) { as_enum :gender, %w{male female} }
    let(:object) { klass.create(gender: :male) }

    it 'does not raise error "private method attribute_was called"' do
      object.gender = :female
      expect do
        expect(object.gender_changed?).to be_truthy
        expect(object.gender_was).to eq :male
      end.to_not raise_error
    end

    context 'github.com/lwe/simple_enum/issues/109' do
      fake_active_record(:klass) {
        as_enum(:gender_cd, %w{female male}, source: :gender_cd)
        as_enum(:role_cd, %w{completed cap dnf dns}, map: :string, source: :role_cd)
      }
      let(:object) { klass.create(role_cd: "cap", gender_cd: :female) }

      context '#gender_cd_was' do
        it 'returns nil when nil' do
          expect(klass.create.gender_cd_was).to be_nil
        end

        it 'returns the current gender' do
          expect(object.gender_cd_was).to eq :female
        end

        it 'returns the old gender' do
          object.gender_cd = :male
          expect(object.gender_cd_was).to eq :female
        end
      end

      context '#role_cd_was' do
        it 'returns nil when nil' do
          expect(klass.create.role_cd_was).to be_nil
        end

        it 'returns the current role' do
          expect(object.role_cd_was).to eq :cap
        end

        it 'returns completed when changed' do
          object.role_cd = :completed
          expect(object.role_cd_was).to eq :cap
        end
      end
    end
  end

  context '#scope' do
    fake_active_record(:klass) { as_enum :gender, [:male, :female] }
    let(:accessor) { described_class::Accessor.new(:gender, enum) }
    subject { accessor.scope(klass, 1) }

    it 'returns an ActiveRecord::Relation' do
      expect(subject).to be_a(ActiveRecord::Relation)
    end

    it "queries for gender_cd = 1" do
      values_hash = { "gender_cd" => 1 }
      expect(subject.where_values_hash).to eq values_hash
    end
  end

  context 'IgnoreAccessor' do
    subject { described_class::IgnoreAccessor.new(:gender, enum) }

    it 'sets gender_cd to 0 with symbol' do
      expect(subject.write(object, :male)).to_not be_falsey
      expect(object.gender_cd).to eq 0
    end

    it 'sets gender_cd to 1 via value (1)' do
      expect(subject.write(object, 1)).to_not be_falsey
      expect(object.gender_cd).to eq 1
    end

    it 'sets gender_cd to nil' do
      expect(subject.write(object, nil)).to be_falsey
      expect(object.gender_cd).to be_nil
    end

    it 'keeps existing value when unknown value is passed' do
      object.gender_cd = 1
      expect(subject.write(object, :other)).to be_falsey
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
