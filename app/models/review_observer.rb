class ReviewObserver < ActiveRecord::Observer

  def after_create(review)
    if review.any.user_id != review.user_id &&
       review.any.user.email_comment_notification
      UserMailer.deliver_review_notification(review)
    end
    
    StuffEvent.create({
        :topic_id => review.topic_id,
        :review_id => review.id,
        :user_id => review.user_id,
        :event_type => StuffEvent::TYPE_REVIEW
    }.merge(review.map_any))
  end

  def after_update(review)
    StuffEvent.create({
        :topic_id => review.topic_id,
        :review_id => review.id,
        :user_id => review.user_id,
        :event_type => StuffEvent::TYPE_REVIEW_UPDATE
    }.merge(review.map_any))
  end

end
