class ReviewObserver < ActiveRecord::Observer

  def after_create(review)
    # This settings need to be changed.
    if review.any.user.email_comment_notification
      if (review.user_id != review.any.user_id || !(review.any.extra_notification_recipients || []).empty?)
        UserMailer.deliver_review_notification(review)
      end
    end
    
    StuffEvent.create({
        :topic_id => review.topic_id,
        :restaurant_id => review.restaurant_id,
        :review_id => review.id,
        :user_id => review.user_id,
        :event_type => StuffEvent::TYPE_REVIEW
    }.merge(review.map_any))
  end

  def after_update(review)
    StuffEvent.create({
        :topic_id => review.topic_id,
        :restaurant_id => review.restaurant_id,
        :review_id => review.id,
        :user_id => review.user_id,
        :event_type => StuffEvent::TYPE_REVIEW_UPDATE
    }.merge(review.map_any))
  end

end
