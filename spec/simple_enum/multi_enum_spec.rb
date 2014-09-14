require 'spec_helper'

describe SimpleEnum::Enums do
  let(:hash) do
    { "iphone" => 0, "ipad" => 1, "macbook" => 2 }
  end

  fake_model(:klass)
  let(:object) { klass.new }

  context 'MultiEnum' do
    subject { described_class::MultiEnum.new(:favorites, hash) }

    context '#value (aliased to #[])' do
      it 'looks up by strings' do
        expect(subject.value(['iphone', 'ipad'])).to eq [0, 1]
        expect(subject[['iphone', 'ipad']]).to eq [0, 1]
      end

      it 'looks up by symbols' do
        expect(subject.value([:iphone, :macbook])).to eq [0, 2]
        expect(subject[[:iphone, :macbook]]).to eq [0, 2]
      end

      it 'looks up by values' do
        expect(subject.value([1, 2])).to eq [1, 2]
        expect(subject[[1, 2]]).to eq [1, 2]
      end

      it 'looks up by mix values' do
        expect(subject.value(['iphone', :ipad, 2])).to eq [0, 1, 2]
        expect(subject[['iphone', :ipad, 2]]).to eq [0, 1, 2]
      end

      it 'returns [] when keys is not found' do
        expect(subject.value([:ohter])).to eq []
        expect(subject[[:ohter]]).to eq []
      end

      it 'returns [] when part of keys is not found' do
        expect(subject.value([0, :ipad, :ohter])).to eq [0, 1]
        expect(subject[[0, :ipad, :ohter]]).to eq [0, 1]
      end
    end

    context '#key' do
      it 'returns symbolized key for supplied value' do
        expect(subject.key([0])).to eq [:iphone]
        expect(subject.key([1, 2])).to eq [:ipad, :macbook]
      end

      it 'returns nil if value is not found' do
        expect(subject.key([12])).to eq []
      end
    end

    context '#match?' do
      it 'returns false when value is nil' do
        expect(subject.match?([:ipad], nil)).to be_falsey
      end

      it 'returns true when values contain keys' do
        expect(subject.match?([:iphone], [0, 1])).to be_truthy
      end

      it 'returns false when values not contain keys' do
        expect(subject.match?([:ipad], [0, 2])).to be_falsey
      end

      it 'returns false when keys include :other' do
        expect(subject.match?([:other, :ipad], [0, 1, 2])).to be_falsey
      end
    end

    context '#include?' do
      it 'returns true by strings' do
        expect(subject.include?(['ipad'])).to be_truthy
      end

      it 'returns true by symbols' do
        expect(subject.include?([:iphone, :macbook])).to be_truthy
      end

      it 'returns true by checking actual values' do
        expect(subject.include?([1, 2])).to be_truthy
      end

      it 'returns false when neither in keys nor values' do
        expect(subject.include?([:other])).to be_falsey
        expect(subject.include?([12])).to be_falsey
      end
    end
  end
end
