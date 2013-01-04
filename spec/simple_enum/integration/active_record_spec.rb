require 'spec_helper'
require 'simple_enum'
require 'simple_enum/integration/active_record'

describe SimpleEnum::Integration::ActiveRecord, :activerecord => true do
  class ActiveRecordDummy < ActiveRecord::Base
    as_enum :gender, %w{male female}
    as_enum :alternative, %w{alpha beta gamma}, :column => 'other'
  end

  before do
    ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'
    ActiveRecord::Base.connection.create_table :active_record_dummies, :force => true do |t|
      t.column :gender_cd, :integer
      t.column :other, :integer
    end
  end

  context "as_enum :gender" do
    subject { ActiveRecordDummy.new(:gender => :male) }
    its(:gender_cd) { should == 0}
    its(:gender) { should == :male }

    context "bang methods" do
      subject { ActiveRecordDummy.create }
      its(:gender) { should be_nil }

      it "saves gender_cd when calling female!" do
        subject.female!
        subject.reload
        subject.gender.should == :female
        subject.gender_cd.should == 1
      end
    end

    context 'dirty attributes' do
      subject { ActiveRecordDummy.create(:gender => 'male') }
      before { subject.female }

      its(:gender_changed?) { should be_true }
      its(:gender_was) { should == :male }
      its(:gender_cd_was) { should == 0 }
    end
  end

  context ':column option' do
    subject { ActiveRecordDummy.new(:alternative => 'beta') }
    its(:alternative) { should == :beta }
    its(:other) { should == 1 }
  end
end
