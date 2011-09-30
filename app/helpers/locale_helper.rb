module LocaleHelper

  SUPPORTED_LOCALES = [
      'en', 'bn', 'ar'
  ].freeze

  def detect_locale
    locale = params[:l]
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

    # Set fall backs
#    if @locale
#      if @locale.to_s.match(/_(en|bn)$/)
#        case $1
#          when 'en'
#            I18n.fallbacks.map(@locale.to_sym => [:en, 'en-US'])
#          when 'bn'
#            I18n.fallbacks.map(@locale.to_sym => [:bn, 'en-US'])
#        end
#      end
#    end
  end

  def valid_locale?(locale)
    if locale && !locale.blank?
      # Remove .js format
      locale = locale.to_s.split('.').first

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
