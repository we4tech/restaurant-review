module LocaleHelper

  SUPPORTED_LOCALES = [
      'en', 'bn', 'ar'
  ].freeze

  def detect_locale
    # Remove .js format
    locale = params[:l].to_s.split('.').first

    @locale = valid_locale?(locale)

    if @locale.nil?
      if topic_wise_valid?("#{@topic.name}_en")
        @locale = "#{@topic.name}_en"
      else
        @locale = I18n.default_locale
      end
    else
      if topic_wise_valid?("#{@topic.name}_#{@locale}")
        @locale = "#{@topic.name}_#{@locale}"
      end
    end

    I18n.locale = @locale

  end

  def valid_locale?(locale)
    if locale && !locale.blank?
      if SUPPORTED_LOCALES.include?(locale.to_s) || topic_wise_valid?(locale.to_s)
        locale
      else
        nil
      end
    else
      nil
    end
  end

  def topic_wise_valid?(locale)
    I18n.available_locales.include?(locale.to_sym)
  end

end
