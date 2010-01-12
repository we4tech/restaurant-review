class ReviewObserver < ActiveRecord::Observer

  def after_create(review)
    if review.restaurant.user.email_comment_notification
      UserMailer.deliver_review_notification(review)
    end
  end

end
