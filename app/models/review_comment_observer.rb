class ReviewCommentObserver < ActiveRecord::Observer

  def after_create(review_comment)
    if review_comment.review.user_id != review_comment.user_id &&
       review_comment.review.user.email_comment_notification
      UserMailer.deliver_comment_notification(review_comment) rescue nil
    end

    notify_other_participants(review_comment)

    StuffEvent.create(
        :topic_id => review_comment.topic_id,
        :restaurant_id => review_comment.restaurant_id,
        :user_id => review_comment.user_id,
        :review_id => review_comment.review.id,
        :review_comment_id => review_comment.id,
        :event_type => StuffEvent::TYPE_REVIEW_COMMENT)
  end

  def after_destroy(review_comment)
    event = StuffEvent.find(:first, :conditions => {
        :topic_id => review_comment.topic_id,
        :user_id => review_comment.user_id,
        :review_comment_id => review_comment.id})
    event.destroy if event
  end

  private
  def notify_other_participants(review_comment)
    participants = review_comment.review.review_comments.
        collect{|rc| rc.user if rc.user_id != review_comment.user_id &&
        rc.user_id != review_comment.review.user_id}.
        compact

    if !participants.empty?
      participants.each do |participant|
        UserMailer.deliver_comment_participants_notification(participant, review_comment) rescue nil
      end
    end
  end
end
