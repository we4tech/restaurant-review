class ReviewObserver < ActiveRecord::Observer

  def after_create(review)
    if review.restaurant.user_id != review.user_id &&
       review.restaurant.user.email_comment_notification
      UserMailer.deliver_review_notification(review) rescue nil
    end

    StuffEvent.create(
        :topic_id => review.topic_id,
        :restaurant_id => review.restaurant_id,
        :review_id => review.id,
        :user_id => review.user_id,
        :event_type => StuffEvent::TYPE_REVIEW)
  end

  def after_update(review)
    StuffEvent.create(
        :topic_id => review.topic_id,
        :restaurant_id => review.restaurant_id,
        :review_id => review.id,
        :user_id => review.user_id,
        :event_type => StuffEvent::TYPE_REVIEW_UPDATE)
  end

end
