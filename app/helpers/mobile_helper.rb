module MobileHelper

  NON_MOBILE_FORMATS = ['html', 'ajax']

  def detect_mobile_view
    if params[:format].to_s.downcase == 'mobile'
      @mobile = true
      session[:mobile_format] = true
    elsif NON_MOBILE_FORMATS.include? params[:format].to_s.downcase
      session[:mobile_format] = nil
      @mobile = false
    elsif session[:mobile_format]
      @mobile = true
      params[:format] = 'mobile'
    elsif mobile_device?
      @mobile = true
      session[:mobile_format] = true
      params[:format] = 'mobile'
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
