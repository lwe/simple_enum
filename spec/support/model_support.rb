require 'active_record'
require 'mongoid'

module ModelSupport
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods

    def fake_active_record(name, &block)
      let(name) {
        Class.new(ActiveRecord::Base) do
          self.table_name = 'dummies'
          instance_eval &block
        end
      }
    end

    def fake_mongoid_model(name, &block)
      let(name) {
        Class.new do
          include Mongoid::Document
          include SimpleEnum::Mongoid

          store_in collection: 'dummies'
          instance_eval &block
        end
      }
    end

    def fake_model(name, *fields, &block)
      fields << :gender_cd
      let(name) {
        Struct.new(*fields) do
          extend ActiveModel::Translation
          extend SimpleEnum::Attribute
          instance_eval &block if block_given?

          def self.model_name
            @model_name ||= ActiveModel::Name.new(self, nil, "FakeModel")
          end
        end
      }
    end
  end
end
