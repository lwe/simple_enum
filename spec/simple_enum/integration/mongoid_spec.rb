require 'spec_helper'
require 'mongoid'
require 'simple_enum/integration/mongoid'

describe SimpleEnum::Integration::Mongoid, :mongoid => true do
  class MongoidDummy
    include Mongoid::Document
    include SimpleEnum::Mongoid
    self.collection_name = 'mongoid_dummies'

    as_enum :gender, [:male, :female]
    as_enum :alternative, [:alpha, :beta, :gamma], :column => 'other'
  end

  before do
    Mongoid.configure do |config|
      config.master = Mongo::Connection.new('localhost').db("simple-enum-test-suite")
      config.use_utc = true
      config.include_root_in_json = true
    end

    Mongoid.master.collections.select do |collection|
      collection.name !~ /system/
    end.each(&:drop)
  end

  context "as_enum :gender" do
    subject { MongoidDummy.new(:gender => :male) }
    its(:gender_cd) { should == 0}
    its(:gender) { should == :male }

    context "bang methods" do
      subject { MongoidDummy.create }
      its(:gender) { should be_nil }

      it "saves gender_cd when calling female!" do
        subject.female!
        subject.reload
        subject.gender.should == :female
        subject.gender_cd.should == 1
      end
    end

    context 'dirty attributes' do
      subject { MongoidDummy.create(:gender => 'male') }
      before { subject.female }

      its(:gender_changed?) { should be_true }
      its(:gender_was) { should == :male }
      its(:gender_cd_was) { should == 0 }
    end
  end

  context ':column option' do
    subject { MongoidDummy.new(:alternative => 'beta') }
    its(:alternative) { should == :beta }
    its(:other) { should == 1 }
  end
end
