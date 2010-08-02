module LocaleHelper

  SUPPORTED_LOCALES = ['en', 'bn', 'ar']

  def detect_locale
    locale = params[:l] || session[:l]
    @locale = if_valid(locale) || :en
    I18n.locale = @locale
    session[:l] = @locale
  end

  def if_valid(locale)
    if SUPPORTED_LOCALES.include?(locale.to_s)
      locale
    else
      nil
    end
  end

end
