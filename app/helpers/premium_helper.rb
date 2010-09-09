module PremiumHelper

  def set_premium_session
    session[:premium] = true
  end

  def unset_premium_session
    session[:premium] = nil
  end

  def premium?
    return true if @premium
    return true if session[:premium]
    false
  end
end
