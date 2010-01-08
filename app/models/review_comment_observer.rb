class ReviewCommentObserver < ActiveRecord::Observer

  def after_create(review_comment)
    if review_comment.review.user.email_comment_notification
      UserMailer.deliver_comment_notification(review_comment)
    end
  end
end
