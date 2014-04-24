require 'spec_helper'

describe SimpleEnum do
  context 'class_methods: scopes' do
    EnumWithScopes = DatabaseSupport.dummy do
      as_enum :gender, [:male, :female], scopes: true
    end

    shared_examples_for 'returning a relation' do |value|
      it 'returns an ActiveRecord::Relation' do
        expect(subject).to be_a(ActiveRecord::Relation)
      end

      it "queries for gender_cd = #{value}" do
        values_hash = { "gender_cd" => value }
        expect(subject.where_values_hash).to eq values_hash
      end
    end

    context '.male' do
      subject { EnumWithScopes.male }
      it_behaves_like 'returning a relation', 0
    end

    context '.female' do
      subject { EnumWithScopes.female }
      it_behaves_like 'returning a relation', 1
    end
  end
end
