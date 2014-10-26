require 'spec_helper'

describe SimpleEnum::Accessors do
  let(:enum) { SimpleEnum::Enum.new(:roles, "user" => 0, "manager" => 1, "admin" => 2) }
  fake_model_multi(:klass)
  let(:object) { klass.new }

  context '.accessor' do
    it 'returns Multi::Accessor instance if multi: true' do
      expect(described_class.accessor(:roles, enum, multi: true)).to be_a(described_class::Multi::Accessor)
    end

    it 'returns a Multi::WhinyAccessor instance if accessor: :whiny and multi: true' do
      expect(described_class.accessor(:roles, enum, accessor: :whiny, multi: true)).to be_a(described_class::Multi::WhinyAccessor)
    end

    it 'sets source to "roles" if source: :roles' do
      expect(described_class.accessor(:roles, enum, source: :roles).source).to eq 'roles'
    end
  end

  context 'Accessor' do
    subject { described_class::Multi::Accessor.new(:roles, enum) }

    context '#name' do
      it 'returns the enum name as string' do
        expect(subject.name).to eq 'roles'
      end
    end

    context '#to_s' do
      it 'returns the name' do
        expect(subject.to_s).to eq 'roles'
      end
    end

    context '#prefix' do
      it 'returns empty string when prefix is nil' do
        expect(described_class::Multi::Accessor.new(:roles, enum).prefix).to eq ''
      end

      it 'returns roles_ when prefix is true' do
        expect(described_class::Multi::Accessor.new(:roles, enum, nil, true).prefix).to eq 'roles_'
      end

      it 'returns other_ when prefix is "other"' do
        expect(described_class::Multi::Accessor.new(:roles, hash, nil, 'other').prefix).to eq 'other_'
      end
    end

    context '#source' do
      it 'returns roles_cd when source is nil' do
        expect(described_class::Multi::Accessor.new(:roles, hash).source).to eq 'roles_cd'
      end

      it 'returns "some_column" when source is set to :some_column' do
        expect(described_class::Multi::Accessor.new(:roles, hash, :some_column).source).to eq 'some_column'
      end

      it 'returns "roles" when source is set to "roles"' do
        expect(described_class::Multi::Accessor.new(:roles, hash, 'roles').source).to eq 'roles'
      end
    end

    context '#read' do
      shared_examples_for 'reading an enum' do
        it 'returns nil then roles_cd is nil' do
          expect(subject.read(object)).to be_nil
        end

        it 'returns [:user] when roles_cd is [0]' do
          expect(subject.read(klass.new([0]))).to eq [:user]
        end

        it 'returns [:manager] when roles_cd is [1]' do
          expect(subject.read(klass.new([1]))).to eq [:manager]
        end

        it 'returns [:user, :admin] when roles_cd is [0, 2]' do
          expect(subject.read(klass.new([0, 2]))).to eq [:user, :admin]
        end
      end

      it_behaves_like 'reading an enum'

      context 'with name == source' do
        subject { described_class::Multi::Accessor.new(:roles_cd, enum, :roles_cd) }
        it_behaves_like 'reading an enum'
      end
    end

    context '#write' do
      shared_examples_for 'writing an enum' do
        it 'writes nil to object' do
          object = klass.new([0])
          expect(subject.write(object, nil)).to be_nil
          expect(object.roles_cd).to be_nil
        end

        it 'writes [1] to object with :manager' do
          expect(subject.write(object, :manager)).to eq :manager
          expect(object.roles_cd).to eq [1]
        end

        it 'writes [0, 2] to object with ["user", "admin"]' do
          expect(subject.write(object, [:user, :admin])).to eq [:user, :admin]
          expect(object.roles_cd).to eq [0, 2]
        end

        it 'writes [0] to object with "user"' do
          expect(subject.write(object, 'user')).to eq 'user'
          expect(object.roles_cd).to eq [0]
        end

        it 'writes [0, 2] to object with ["user", "admin"]' do
          expect(subject.write(object, ['user', 'admin'])).to eq ['user', 'admin']
          expect(object.roles_cd).to eq [0, 2]
        end

        it 'writes [1] to object with 1' do
          expect(subject.write(object, 1)).to eq 1
          expect(object.roles_cd).to eq [1]
        end

        it 'writes nil to object with :other' do
          object = klass.new([1])
          expect(subject.write(object, :other)).to be_nil
          expect(object.roles_cd).to be_nil
        end

        it 'writes nil to object with [:other]' do
          object = klass.new([1])
          expect(subject.write(object, [:other])).to be_nil
          expect(object.roles_cd).to be_nil
        end

        it 'writes nil to object with [:user, :other]' do
          object = klass.new([1])
          expect(subject.write(object, [:user, :other])).to be_nil
          expect(object.roles_cd).to be_nil
        end
      end

      it_behaves_like 'writing an enum'

      context 'with name == source' do
        subject { described_class::Multi::Accessor.new(:roles_cd, enum, :roles_cd) }
        it_behaves_like 'writing an enum'
      end
    end

    context '#selected?' do
      it 'returns false when roles_cd is nil' do
        expect(subject.selected?(object)).to be_falsey
        expect(subject.selected?(object, :user)).to be_falsey
        expect(subject.selected?(object, [:user])).to be_falsey
        expect(subject.selected?(object, [:user, :admin])).to be_falsey
      end

      it 'returns true when roles_cd is != nil' do
        expect(subject.selected?(klass.new([0]))).to be_truthy
        expect(subject.selected?(klass.new([1]))).to be_truthy
        expect(subject.selected?(klass.new([0, 2]))).to be_truthy
      end

      it 'returns true when roles_cd is [0] and :user is passed' do
        expect(subject.selected?(klass.new([0]), :user)).to be_truthy
      end

      it 'returns true when roles_cd is [0] and [:user] is passed' do
        expect(subject.selected?(klass.new([0]), [:user])).to be_truthy
      end

      it 'returns true when roles_cd is [0, 1] and [:user] is passed' do
        expect(subject.selected?(klass.new([0, 1]), [:user])).to be_truthy
      end

      it 'returns true when roles_cd is [0, 1] and [:user, :manager] is passed' do
        expect(subject.selected?(klass.new([0, 1]), [:user, :manager])).to be_truthy
      end

      it 'returns true when roles_cd is [0, 1, 2] and [:user, :manager] is passed' do
        expect(subject.selected?(klass.new([0, 1, 2]), [:user, :manager])).to be_truthy
      end

      it 'returns false when roles_cd is [0] and :manager is passed' do
        expect(subject.selected?(klass.new([0]), :manager)).to be_falsey
      end

      it 'returns false when roles_cd is [0] and [:manager] is passed' do
        expect(subject.selected?(klass.new([0]), [:manager])).to be_falsey
      end

      it 'returns false when roles_cd is [0] and [:user, :manager] is passed' do
        expect(subject.selected?(klass.new([0]), [:user, :manager])).to be_falsey
      end

      it 'returns false when roles_cd is [0, 2] and [:manager] is passed' do
        expect(subject.selected?(klass.new([0, 2]), [:manager])).to be_falsey
      end

      it 'returns false when roles_cd is [0, 2] and [:user, :manager] is passed' do
        expect(subject.selected?(klass.new([0, 2]), [:user, :manager])).to be_falsey
      end

      it 'returns false when roles_cd is [0] and :other is passed' do
        expect(subject.selected?(klass.new([0]), :other)).to be_falsey
      end

      it 'returns false when roles_cd is [0] and [:other] is passed' do
        expect(subject.selected?(klass.new([0]), [:other])).to be_falsey
      end

      it 'returns false when roles_cd is [0] and [:user, :other] is passed' do
        expect(subject.selected?(klass.new([0]), [:user, :other])).to be_falsey
      end
    end

    context '#changed?' do
      it 'delegates to attribute_changed?' do
        expect(object).to receive(:attribute_changed?).with('roles_cd') { true }
        expect(subject.changed?(object)).to be_truthy
      end
    end

    context 'was' do
      it 'delegates to attribute_was and resolves symbol' do
        expect(object).to receive(:attribute_was).with('roles_cd') { 1 }
        expect(subject.was(object)).to eq [:manager]
      end

    end
  end

  context 'dirty attributes on ActiveModel', active_record: true do
    fake_active_record(:klass) do
      serialize :roles_cd
      as_enum :roles, %w{user manager}, multi: true
    end
    let(:object) { klass.create(roles: :user) }

    it 'does not raise error "private method attribute_was called"' do
      object.roles = :manager
      expect do
        expect(object.roles_changed?).to be_truthy
        expect(object.roles_was).to eq [:user]
      end.to_not raise_error
    end
  end

  context 'IgnoreAccessor' do
    subject { described_class::Multi::IgnoreAccessor.new(:roles, enum) }

    it 'sets roles_cd to 0 with symbol' do
      expect(subject.write(object, :user)).to_not be_falsey
      expect(object.roles_cd).to eq [0]
    end

    it 'sets roles_cd to 0 with single-symbol array' do
      expect(subject.write(object, [:user])).to_not be_falsey
      expect(object.roles_cd).to eq [0]
    end

    it 'sets roles_cd to 0 with multi-symbol array' do
      expect(subject.write(object, [:user, :admin])).to_not be_falsey
      expect(object.roles_cd).to eq [0, 2]
    end

    it 'sets roles_cd to 1 via value (1)' do
      expect(subject.write(object, 1)).to_not be_falsey
      expect(object.roles_cd).to eq [1]
    end

    it 'sets roles_cd to 1 via single-value array [1]' do
      expect(subject.write(object, [1])).to_not be_falsey
      expect(object.roles_cd).to eq [1]
    end

    it 'sets roles_cd to 1 via multi-value array [0, 2]' do
      expect(subject.write(object, [0, 2])).to_not be_falsey
      expect(object.roles_cd).to eq [0, 2]
    end

    it 'sets roles_cd to nil' do
      expect(subject.write(object, nil)).to be_falsey
      expect(object.roles_cd).to be_nil
    end

    it 'keeps existing value when unknown value is passed' do
      object.roles_cd = [1]
      expect(subject.write(object, :other)).to be_falsey
      expect(object.roles_cd).to eq [1]
    end
  end

  context 'WhinyAccessor' do
    subject { described_class::Multi::WhinyAccessor.new(:roles, enum) }

    it 'raises no error when setting existing key' do
      expect { subject.write(object, :user) }.to_not raise_error
      expect(object.roles_cd).to eq [0]
    end

    it 'raises no error when setting existing single-key array' do
      expect { subject.write(object, [:user]) }.to_not raise_error
      expect(object.roles_cd).to eq [0]
    end

    it 'raises no error when setting existing multi-key array' do
      expect { subject.write(object, [:user, :admin]) }.to_not raise_error
      expect(object.roles_cd).to eq [0, 2]
    end

    it 'raises no error when setting with existing value' do
      expect { subject.write(object, 1) }.to_not raise_error
      expect(object.roles_cd).to eq [1]
    end

    it 'raises no error when setting with existing single-value array' do
      expect { subject.write(object, [1]) }.to_not raise_error
      expect(object.roles_cd).to eq [1]
    end

    it 'raises no error when setting with existing multi-value array' do
      expect { subject.write(object, [1, 2]) }.to_not raise_error
      expect(object.roles_cd).to eq [1, 2]
    end

    it 'raises no error when setting to nil' do
      expect { subject.write(object, nil) }.to_not raise_error
      expect(object.roles_cd).to be_nil
    end

    it 'raises ArgumentError when setting invalid key' do
      expect { subject.write(object, :other) }.to raise_error(ArgumentError)
    end
  end
end
