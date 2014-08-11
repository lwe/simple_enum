module I18nSupport
  def self.included(base)
    base.let!(:i18n_previous_backend) { I18n.backend }
    base.let(:i18n_backend) { I18n::Backend::Simple.new() }
    base.before { I18n.backend = i18n_backend }
    base.after { I18n.backend = i18n_previous_backend }
  end

  def store_translations(lang, translations)
    i18n_backend.store_translations lang, translations
  end
end
