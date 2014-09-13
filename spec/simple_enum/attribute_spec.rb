require 'spec_helper'

describe SimpleEnum::Attribute do
  fake_model(:klass) { as_enum :gender, %w{male female}, with: [] }
  let(:accessor) { subject.class.genders_accessor }

  context '.as_enum' do
    it 'returns a SimpleEnum::Enums::Enum' do
      expect(klass.as_enum(:gender, %w{male female})).to be_a(SimpleEnum::Enums::Enum)
    end
  end

  context 'generate_enum_class_accessors_for' do
    context '.genders' do
      subject { klass.genders }

      it 'returns a SimpleEnum::Enums::Enum' do
        expect(subject).to be_a(SimpleEnum::Enums::Enum)
      end
    end

    context '.genders_accessor' do
      subject { klass.genders_accessor }

      it 'returns a SimpleEnum::Accessor' do
        expect(subject).to be_a(SimpleEnum::Accessors::Accessor)
      end
    end
  end

  context 'generate_enum_instance_accessors_for' do
    subject { klass.new(1) }

    context '#gender' do
      it 'delegates to accessor' do
        expect(accessor).to receive(:read).with(subject) { :female }
        expect(subject.gender).to eq :female
      end
    end

    context '#gender=' do
      it 'delegates to accessor' do
        expect(accessor).to receive(:write).with(subject, :male) { 0 }
        subject.gender = :male
      end
    end

    context '#gender?' do
      it 'delegates to accessor' do
        expect(accessor).to receive(:selected?).with(subject, nil) { nil }
        expect(subject.gender?).to be_falsey
      end
    end
  end

  context 'generate_enum_dirty_methods_for' do
    subject { klass.new }

    it 'does not respond to #gender_changed?' do
      expect(subject).to_not respond_to(:gender_changed?)
    end

    it 'does not responds to #gender_was' do
      expect(subject).to_not respond_to(:gender_was)
    end

    context 'with: :dirty' do
      fake_model(:klass_with_dirty) { as_enum :gender, %w{male female}, with: [:dirty] }
      subject { klass_with_dirty.new }

      it 'delegates #gender_changed? to accessor' do
        expect(accessor).to receive(:changed?).with(subject) { true }
        expect(subject.gender_changed?).to be_truthy
      end

      it 'delegates #gender_was to accesso' do
        expect(accessor).to receive(:was).with(subject) { :female }
        expect(subject.gender_was).to eq :female
      end
    end
  end

  context 'generate_enum_attribute_methods_for' do
    subject { klass.new }

    it 'does not respond to #male? or #female?' do
      expect(subject).to_not respond_to(:male?)
      expect(subject).to_not respond_to(:female?)
    end

    it 'does not respond to #male! or #female!' do
      expect(subject).to_not respond_to(:male!)
      expect(subject).to_not respond_to(:female!)
    end

    context 'with: :attribute' do
      fake_model(:klass_with_attributes) { as_enum :gender, %w{male female}, with: [:attribute] }
      subject { klass_with_attributes.new }

      it 'delegates #gender? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, nil) { :female }
        expect(subject.gender?).to be_truthy
      end

      it 'delegates #male? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, 'male') { true }
        expect(subject.male?).to be_truthy
      end

      it 'delegates #female? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, 'female') { false }
        expect(subject.female?).to be_falsey
      end

      it 'delegates #male! to accessor' do
        expect(accessor).to receive(:write).with(subject, 'male') { 0 }
        expect(subject.male!).to eq 0
      end

      it 'delegates #female! to accessor' do
        expect(accessor).to receive(:write).with(subject, 'female') { 1 }
        expect(subject.female!).to eq 1
      end
    end

    context 'with a prefix' do
      fake_model(:klass_with_prefix) { as_enum :gender, %w{male female}, with: [:attribute], prefix: true }
      subject { klass_with_prefix.new }

      it 'delegates #gender? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, nil) { :female }
        expect(subject.gender?).to be_truthy
      end

      it 'delegates #gender_male? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, 'male') { true }
        expect(subject.gender_male?).to be_truthy
      end

      it 'delegates #gender_female? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, 'female') { false }
        expect(subject.gender_female?).to be_falsey
      end

      it 'delegates #gender_male! to accessor' do
        expect(accessor).to receive(:write).with(subject, 'male') { 0 }
        expect(subject.gender_male!).to eq 0
      end

      it 'delegates #gender_female! to accessor' do
        expect(accessor).to receive(:write).with(subject, 'female') { 1 }
        expect(subject.gender_female!).to eq 1
      end
    end
  end

  context 'generate_enum_scope_methods_for', active_record: true do
    fake_active_record(:klass) {
      as_enum :gender, [:male, :female], with: [:scope]
    }

    shared_examples_for 'returning a relation' do |value|
      it 'returns an ActiveRecord::Relation' do
        expect(subject).to be_a(ActiveRecord::Relation)
      end

      it "queries for gender_cd = #{value}" do
        values_hash = { "gender_cd" => value }
        expect(subject.where_values_hash).to eq values_hash
      end
    end

    context '.males' do
      subject { klass.males }
      it_behaves_like 'returning a relation', 0
    end

    context '.females' do
      subject { klass.females }
      it_behaves_like 'returning a relation', 1
    end

    context 'with prefix' do
      fake_active_record(:klass) {
        as_enum :gender, [:male, :female], with: [:scope], prefix: true
      }

      context '.gender_males' do
        subject { klass.gender_males }
        it_behaves_like 'returning a relation', 0
      end

      context '.gender_females' do
        subject { klass.gender_females }
        it_behaves_like 'returning a relation', 1
      end
    end

    context 'without scope method' do
      fake_model(:klass_without_scope_method) {
        as_enum :gender, [:male, :female], with: [:scope]
      }
      subject { klass_without_scope_method }

      it 'does not add .males nor .females' do
        expect(subject).to_not respond_to(:males)
        expect(subject).to_not respond_to(:females)
      end
    end
  end
end
