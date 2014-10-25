require 'spec_helper'

describe SimpleEnum::Attribute do
  fake_model(:klass) { as_enum :roles, %w{user manager}, with: [], multi: true }
  let(:accessor) { subject.class.roles_accessor }

  context '.as_enum' do
    it 'returns a SimpleEnum::Enum' do
      expect(klass.as_enum(:roles, %w{user manager}, multi: true)).to be_a(SimpleEnum::Enum)
    end
  end

  context 'generate_enum_class_accessors_for' do
    context '.roles' do
      subject { klass.roles }

      it 'returns a SimpleEnum::Enum' do
        expect(subject).to be_a(SimpleEnum::Enum)
      end
    end

    context '.roles_accessor' do
      subject { klass.roles_accessor }

      it 'returns a SimpleEnum::Accessor' do
        expect(subject).to be_a(SimpleEnum::Accessors::Multi::Accessor)
      end
    end
  end

  context 'generate_enum_instance_accessors_for' do
    subject { klass.new(1) }

    context '#roles' do
      it 'delegates to accessor' do
        expect(accessor).to receive(:read).with(subject) { :manager }
        expect(subject.roles).to eq :manager
      end
    end

    context '#roles=' do
      it 'delegates to accessor' do
        expect(accessor).to receive(:write).with(subject, :user) { 0 }
        subject.roles = :user
      end
    end

    context '#roles?' do
      it 'delegates to accessor' do
        expect(accessor).to receive(:selected?).with(subject, nil) { nil }
        expect(subject.roles?).to be_falsey
      end
    end
  end

  context 'generate_enum_dirty_methods_for' do
    subject { klass.new }

    it 'does not respond to #roles_changed?' do
      expect(subject).to_not respond_to(:roles_changed?)
    end

    it 'does not responds to #roles_was' do
      expect(subject).to_not respond_to(:roles_was)
    end

    context 'with: :dirty' do
      fake_model(:klass_with_dirty) { as_enum :roles, %w{user manager}, with: [:dirty] }
      subject { klass_with_dirty.new }

      it 'delegates #roles_changed? to accessor' do
        expect(accessor).to receive(:changed?).with(subject) { true }
        expect(subject.roles_changed?).to be_truthy
      end

      it 'delegates #roles_was to accesso' do
        expect(accessor).to receive(:was).with(subject) { :manager }
        expect(subject.roles_was).to eq :manager
      end
    end
  end

  context 'generate_enum_attribute_methods_for' do
    subject { klass.new }

    it 'does not respond to #user? or #manager?' do
      expect(subject).to_not respond_to(:user?)
      expect(subject).to_not respond_to(:manager?)
    end

    it 'does not respond to #user! or #manager!' do
      expect(subject).to_not respond_to(:user!)
      expect(subject).to_not respond_to(:manager!)
    end

    context 'with: :attribute' do
      fake_model(:klass_with_attributes) { as_enum :roles, %w{user manager}, with: [:attribute] }
      subject { klass_with_attributes.new }

      it 'delegates #roles? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, nil) { :manager }
        expect(subject.roles?).to be_truthy
      end

      it 'delegates #user? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, 'user') { true }
        expect(subject.user?).to be_truthy
      end

      it 'delegates #manager? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, 'manager') { false }
        expect(subject.manager?).to be_falsey
      end

      it 'delegates #user! to accessor' do
        expect(accessor).to receive(:write).with(subject, 'user') { 0 }
        expect(subject.user!).to eq 0
      end

      it 'delegates #manager! to accessor' do
        expect(accessor).to receive(:write).with(subject, 'manager') { 1 }
        expect(subject.manager!).to eq 1
      end
    end

    context 'with a prefix' do
      fake_model(:klass_with_prefix) { as_enum :roles, %w{user manager}, with: [:attribute], prefix: true }
      subject { klass_with_prefix.new }

      it 'delegates #roles? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, nil) { :manager }
        expect(subject.roles?).to be_truthy
      end

      it 'delegates #roles_user? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, 'user') { true }
        expect(subject.roles_user?).to be_truthy
      end

      it 'delegates #roles_manager? to accessor' do
        expect(accessor).to receive(:selected?).with(subject, 'manager') { false }
        expect(subject.roles_manager?).to be_falsey
      end

      it 'delegates #roles_user! to accessor' do
        expect(accessor).to receive(:write).with(subject, 'user') { 0 }
        expect(subject.roles_user!).to eq 0
      end

      it 'delegates #roles_manager! to accessor' do
        expect(accessor).to receive(:write).with(subject, 'manager') { 1 }
        expect(subject.roles_manager!).to eq 1
      end
    end
  end

  context 'generate_enum_scope_methods_for', active_record: true do
    fake_active_record(:klass) {
      as_enum :roles, [:user, :manager], with: [:scope], multi: true
    }

    it 'does not add .users nor .managers' do
      expect(klass).to_not respond_to(:users)
      expect(klass).to_not respond_to(:managers)
    end

    context 'with prefix' do
      fake_active_record(:klass) {
        as_enum :roles, [:user, :manager], with: [:scope], prefix: true, multi: true
      }

      it 'does not add .roles_users nor .roles_managers' do
        expect(klass).to_not respond_to(:roles_users)
        expect(klass).to_not respond_to(:roles_managers)
      end
    end

    context 'without scope method' do
      fake_model(:klass_without_scope_method) {
        as_enum :roles, [:user, :manager], with: [:scope], multi: true
      }
      subject { klass_without_scope_method }

      it 'does not add .users nor .managers' do
        expect(subject).to_not respond_to(:users)
        expect(subject).to_not respond_to(:managers)
      end
    end
  end
end
