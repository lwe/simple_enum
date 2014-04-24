require 'spec_helper'

describe SimpleEnum do
  context '.as_enum' do
    NonDirty = DatabaseSupport.dummy do
      as_enum :gender, [:male, :female]
    end

    subject { NonDirty.new }

    it 'has dirty attributes disabled by default' do
      expect(subject).to_not respond_to(:gender_changed?)
      expect(subject).to_not respond_to(:gender_was)
    end

    context 'with dirty: true' do
      GettingDirty = DatabaseSupport.dummy do
        as_enum :gender, [:male, :female], dirty: true
      end

      subject { GettingDirty.create!(gender: :male) }
      before { subject.gender = :female }

      it 'returns true for #gender_changed?' do
        expect(subject.gender_changed?).to be_true
      end

      it 'returns :male for #gender_was' do
        expect(subject.gender_was).to eq :male
      end
    end
  end
end
