require 'spec_helper'

describe SimpleEnum::Attribute do
  context 'generate_enum_scope_methods_for' do
    fake_active_record(:klass) {
      as_enum :gender, [:male, :female], with: [:scope]
    }

    fake_model(:klass_without_scope_method) {
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

    context '.male' do
      subject { klass.male }
      it_behaves_like 'returning a relation', 0
    end

    context '.female' do
      subject { klass.female }
      it_behaves_like 'returning a relation', 1
    end

    context 'without scope method' do
      subject { klass_without_scope_method }

      it 'does not respond to .male or .female' do
        expect(subject).to_not respond_to(:male)
        expect(subject).to_not respond_to(:female)
      end
    end
  end
end
