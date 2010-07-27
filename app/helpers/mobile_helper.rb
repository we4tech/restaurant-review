module MobileHelper

  def detect_mobile_view
    if params[:format].to_s.downcase == 'mobile'
      @mobile = true
      session[:mobile_format] = true
    elsif params[:format].to_s.downcase == 'html'
      session[:mobile_format] = nil
      @mobile = false
    elsif session[:mobile_format]
      @mobile = true
      params[:format] = 'mobile'
    end
  end

  def mobile?
    session[:mobile_format]
  end
end
