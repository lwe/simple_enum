module SimpleEnum
  class Railtie < Rails::Railtie
    initializer 'simple_enum.integration' do
      ActiveSupport.on_load(:active_record) do
        require 'simple_enum/integration/active_record'
      end
    end
  end
end
