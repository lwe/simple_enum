require 'spec_helper'
require 'simple_enum/hasher'

describe SimpleEnum::Hasher do
  subject { described_class }

  context '.map' do
    subject { described_class.map(%w{male female}, map: :string) }

    it 'uses DefaultHasher by default' do
      result = { "male" => 0, "female" => 1 }
      expect(described_class.map(%w{male female})).to eq result
    end

    it 'returns a frozen Hash' do
      expect(subject).to be_a(Hash)
      expect(subject).to be_frozen
    end

    it 'uses the builder supplied if available' do
      result = { "male" => "male", "female" => "female" }
      expect(subject).to eq result
    end

    it 'accepts a Proc as well' do
      proc =  ->(hash) { { "static" => 1 } }
      result = { "static" => 1 }
      expect(described_class.map(%w{male female}, map: proc) ).to eq result
    end
  end

  context 'DefaultHasher.call' do
    let(:result) do; { "male" => 0, "female" => 1 } end

    it 'returns string => index for Array of strings' do
      expect(subject::DefaultHasher.call(%w{male female})).to eq result
    end

    it 'returns string => index for Array of symbols' do
      expect(subject::DefaultHasher.call([:male, :female])).to eq result
    end

    it 'returns string => number for Hash with symbolized keys' do
      expect(subject::DefaultHasher.call(male: 0, female: 1)).to eq result
    end

    it 'returns string => number for hash with string keys' do
      expect(subject::DefaultHasher.call('male' => 0, 'female' => 1)).to eq result
    end
  end

  context 'StringHasher.call' do
    let(:result) do; { "male" => "male", "female" => "female" } end

    it 'retuns string => string for Array of strings' do
      expect(subject::StringHasher.call(%w{male female})).to eq result
    end

    it 'returns string => string for Array of symbols' do
      expect(subject::StringHasher.call([:male, :female])).to eq result
    end
  end
end
