require 'simple_enum'

module SimpleEnum
  class Railtie < Rails::Railtie

    initializer 'simple_enum.extend_active_record' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :extend, SimpleEnum::Attribute
        ActiveRecord::Base.send :extend, SimpleEnum::Translation
      end
    end

    initializer 'simple_enum.view_helpers' do
      ActionView::Base.send :include, SimpleEnum::ViewHelpers
    end
  end
end
