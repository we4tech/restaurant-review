module MobileHelper

  NON_MOBILE_FORMATS = ['html', 'ajax']
  MOBILE_DEFAULT_FORMAT = MOBILE_FORMAT = 'mobile'
  MOBILE_TOUCH_FORMAT = 'mobile_touch'

  def detect_mobile_view
    if format_type = params[:format].to_s.downcase =~ /#{MOBILE_FORMAT}|#{MOBILE_TOUCH_FORMAT}/
      @mobile = true
      session[:mobile_format] = format_type
    elsif NON_MOBILE_FORMATS.include? params[:format].to_s.downcase
      session[:mobile_format] = nil
      @mobile = false
    elsif backward_compatible session[:mobile_format]
      @mobile = true
      params[:format] = backward_compatible session[:mobile_format]
    elsif mobile_device?
      @mobile = true
      session[:mobile_format] = params[:format] = MOBILE_DEFAULT_FORMAT
    end
  end

  def backward_compatible(old_format)
    if old_format.is_a?(String)
      old_format
    else
      old_format.is_a?(TrueClass) ? MOBILE_DEFAULT_FORMAT : nil
    end
  end

  def mobile?
    session[:mobile_format]
  end

  def mobile_device?
    mobile_user_agent = 'palm|palmos|palmsource|iphone|blackberry|nokia|phone|midp|mobi|pda|' +
        'wap|java|nokia|hand|symbian|chtml|wml|ericsson|lg|audiovox|motorola|' +
        'samsung|sanyo|sharp|telit|tsm|mobile|mini|windows ce|smartphone|' +
        '240x320|320x320|mobileexplorer|j2me|sgh|portable|sprint|vodafone|' +
        'docomo|kddi|softbank|pdxgw|j-phone|astel|minimo|plucker|netfront|' +
        'xiino|mot-v|mot-e|portalmmm|sagem|sie-s|sie-m|android|ipod'

    request.user_agent.to_s.downcase =~ Regexp.new(mobile_user_agent)
  end
end
