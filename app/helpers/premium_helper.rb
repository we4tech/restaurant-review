module PremiumHelper

  def set_premium_session
    session[:premium] = true
  end

  def unset_premium_session
    session[:premium] = nil
  end

  def premium?
    return true if @premium
    false
  end

  def pt_image_tag(file_name, options = {})
    image_tag("templates/#{@premium_template.template}/#{file_name}", options)
  end
end
