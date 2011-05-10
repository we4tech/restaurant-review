class UserMailer < ActionMailer::Base

  include StringHelper
  include UrlOverrideHelper
  helper :partial_view_helper
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
    
    setup_email(review_comment.review.user, review_comment.topic, review_comment.any)
    @subject += "#{review_comment.user.login.humanize} has commented on your review at '#{review_comment.any.name}'"
    @body[:review_comment] = review_comment
    @body[:url] = "#{event_or_restaurant_url(review_comment.any, :format => 'html')}#review-#{review_comment.review_id}"
    @body[:topic] = review_comment.topic
  end

  def comment_participants_notification(participant, review_comment)
    css :fresh

    setup_email(participant, review_comment.topic, review_comment.any)
    @subject += "#{review_comment.user.login.humanize} has commented after your comment at '#{review_comment.any.name}'"
    @body[:review_comment] = review_comment
    @body[:participant] = participant
    @body[:url] = "#{event_or_restaurant_url(review_comment.any, :format => 'html')}#review-#{review_comment.review_id}"
    @body[:topic] = review_comment.topic
  end

  def review_notification(review)
    css :fresh

    setup_email(review.any.user, review.topic, review.any)
    @subject += "#{review.user.login.humanize} has reviewed your #{review.topic.subdomain} '#{review.any.name}'"
    @body[:review] = review
    @body[:url] = event_or_restaurant_url(review.any, :format => 'html')
    @body[:topic] = review.topic
  end

  def server_status_notification(subject, message)
    restaurant = Restaurant.first
    user = User.find_by_email('hasan83bd@gmail.com')

    setup_email(user, Topic.default)
    @subject += subject
    @body[:message] = message
  end

  protected
    def setup_email(user, topic, restaurant_or_event = nil)
      emails_recipients = []

      if (restaurant_or_event && restaurant_or_event.user_id != user.id)
        emails_recipients << "#{user.email}"
      end

      if restaurant_or_event && !(restaurant_or_event.extra_notification_recipients || []).empty?
        restaurant_or_event.extra_notification_recipients.each{|e| emails_recipients << e}
      end

      @recipients  = emails_recipients

      @from        = "Notification <support@welltreat.us>"
      @subject     = "[#{topic.public_host}] "
      @sent_on     = Time.now
      @body[:user] = user
    end
end
