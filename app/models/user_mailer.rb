class UserMailer < ActionMailer::Base

  include UrlOverrideHelper
  helper :restaurants
  helper :url_override
  helper :topic_based_translation
  helper :string
  helper :mail_supporting

  def signup_notification(user)
    setup_email(user, Topic.default)
    @subject    += 'Please activate your new account'
  
    @body[:url]  = "http://#{Topic.default.subdomain}.welltreat.us/activate/#{user.activation_code}"
    @body[:topic] = Topic.default
  end
  
  def activation(user)
    setup_email(user, Topic.default)

    @subject    += 'Your account has been activated!'
    @body[:url]  = "http://#{Topic.default.subdomain}.welltreat.us/"
    @body[:topic] = Topic.default
  end

  def reset_password(user)
    topic = nil
    if user.user_logs.last
      topic = user.user_logs.last.topic
    else
      topic = Topic.default
    end

    setup_email(user, topic)

    @subject += 'Your password change request!'
    @body[:url] = change_password_url(user.remember_token,
                                      :subdomain => topic.subdomain)

    @body[:topic] = topic
  end

  def comment_notification(review_comment)
    css :fresh
    
    setup_email(review_comment.review.user, review_comment.topic, review_comment.restaurant)
    @subject += "#{review_comment.user.login.humanize} has commented on your review at '#{review_comment.restaurant.name}'"
    @body[:review_comment] = review_comment
    @body[:url] = "#{restaurant_long_route_url(
        :topic_name => review_comment.topic.subdomain,
        :name => review_comment.restaurant.name.parameterize.to_s,
        :id => review_comment.restaurant.id,
        :subdomain => review_comment.topic.subdomain)}#review-#{review_comment.review_id}"
    @body[:topic] = review_comment.topic
  end

  def comment_participants_notification(participant, review_comment)
    css :fresh

    setup_email(participant, review_comment.topic, review_comment.restaurant)
    @subject += "#{review_comment.user.login.humanize} has commented after your comment at '#{review_comment.restaurant.name}'"
    @body[:review_comment] = review_comment
    @body[:participant] = participant
    @body[:url] = "#{restaurant_long_route_url(
        :topic_name => review_comment.topic.subdomain,
        :name => review_comment.restaurant.name.parameterize.to_s,
        :id => review_comment.restaurant.id,
        :subdomain => review_comment.topic.subdomain)}#review-#{review_comment.review_id}"
    @body[:topic] = review_comment.topic
  end

  def review_notification(review)
    css :fresh
    
    setup_email(review.restaurant.user, review.topic, review.restaurant)
    @subject += "#{review.user.login.humanize} has reviewed your #{review.topic.subdomain} '#{review.restaurant.name}'"
    @body[:review] = review
    @body[:url] = "#{restaurant_long_route_url(
        :topic_name => review.topic.subdomain,
        :name => review.restaurant.name.parameterize.to_s,
        :id => review.restaurant.id,
        :subdomain => review.topic.subdomain)}#review-#{review.id}"
    @body[:topic] = review.topic
  end

  protected
    def setup_email(user, topic, restaurant = nil)
      cc_emails = []

      if restaurant && !(restaurant.extra_notification_recipients || []).empty?
        restaurant.extra_notification_recipients.each{|e| cc_emails << e}
      end

      @recipients  = "#{user.email}"

      if !cc_emails.empty?
        @cc          = cc_emails
      end

      @from        = "Notification <support@welltreat.us>"
      @subject     = "[#{topic ? topic.subdomain : 'www'}.welltreat.us] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
