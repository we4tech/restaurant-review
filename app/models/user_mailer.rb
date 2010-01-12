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

  def comment_notification(review_comment)
    setup_email(review_comment.review.user)
    @subject += "#{review_comment.user.login} has commented on your review at '#{review_comment.restaurant.name}'"
    @body[:review_comment] = review_comment
    @body[:url] = restaurant_long_url(
        :name => review_comment.restaurant.name.parameterize.to_s,
        :id => review_comment.restaurant.id)
  end

  def review_notification(review)
    setup_email(review.restaurant.user)
    @subject += "#{review.user.login} has reviewed your restaurant '#{review.restaurant.name}'"
    @body[:review] = review
    @body[:url] = restaurant_long_url(
        :name => review.restaurant.name.parameterize.to_s,
        :id => review.restaurant.id)
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
