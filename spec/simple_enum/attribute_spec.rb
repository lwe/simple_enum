require 'spec_helper'

describe SimpleEnum::Attribute do
  fake_model(:klass) { as_enum :gender, %w{male female}, with: [] }
  let(:accessor) { subject.class.genders_accessor }

  context '.as_enum' do
    it 'returns a SimpleEnum::Enum' do
      expect(klass.as_enum(:gender, %w{male female})).to be_a(SimpleEnum::Enum)
    end
  end

  context '.register_generator' do
    let(:mod) {
      Module.new do
        def generate_enum_spec_extension_for(enum, accessor)
          module_eval { attr_accessor :some_reader }
          simple_enum_module.module_eval do
            define_method("extension_method") { "as_enum(#{enum.name})" }
          end
        end
      end
    }

    before { SimpleEnum.register_generator :spec, mod }
    after { described_class::EXTENSIONS.clear }

    subject { klass.new }

    it 'adds "spec" to EXTENSIONS' do
      expect(described_class::EXTENSIONS).to eq %w{spec}
    end

    it 'calls generate_enum_spec_extension_for during as_enum' do
      expect(subject.extension_method).to eq "as_enum(gender)"
    end

    it 'allows to add behavior to class itself (e.g. attr_accessor)' do
      subject.some_reader = "some value"
      expect(subject.some_reader).to eq "some value"
    end
  end

  context 'generate_enum_class_accessors_for' do
    context '.genders' do
      subject { klass.genders }

      it 'returns a SimpleEnum::Enum' do
        expect(subject).to be_a(SimpleEnum::Enum)
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

    let(:accessor) { klass.genders_accessor }

    shared_examples_for 'delegates to accessor#scope' do |value|
      it 'delegates to #scope' do
        expect(accessor).to receive(:scope).with(klass, value)
        subject
      end
    end

    context '.males' do
      subject { klass.males }
      it_behaves_like 'delegates to accessor#scope', 0
    end

    context '.females' do
      subject { klass.females }
      it_behaves_like 'delegates to accessor#scope', 1
    end

    context 'with prefix' do
      fake_active_record(:klass) {
        as_enum :gender, [:male, :female], with: [:scope], prefix: true
      }

      context '.gender_males' do
        subject { klass.gender_males }
        it_behaves_like 'delegates to accessor#scope', 0
      end

      context '.gender_females' do
        subject { klass.gender_females }
        it_behaves_like 'delegates to accessor#scope', 1
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
