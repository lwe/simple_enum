module I18nSupport
  extend ActiveSupport::Concern

  included do
    let!(:i18n_previous_backend) { I18n.backend }
    let(:i18n_backend) { I18n::Backend::KeyValue.new({}) }
    before { I18n.backend = i18n_backend }
    after { I18n.backend = i18n_previous_backend }
  end

  def store_translations(lang, translations)
    i18n_backend.store_translations lang, translations
  end
end
