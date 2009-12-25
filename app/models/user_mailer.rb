class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://www.welltreat.us/activate/#{user.activation_code}"
  
  end
  
  def activation(user)
    setup_email(user)
    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://restaurant.welltreat.us/"
  end

  def reset_password(user)
    setup_email(user)
    @subject += 'Your password change request!'
    @body[:url] = change_password_url(user.remember_token)
  end

  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "support"
      @subject     = "[restaurant.welltreat.us] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
