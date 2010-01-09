class ReviewCommentsController < ApplicationController

  before_filter :login_required

  def create
    @review_comment = ReviewComment.new(params[:review_comment])
    @review = Review.find(@review_comment.review_id)

    @review_comment.user_id = current_user.id
    @review_comment.topic_id = @topic.id
    @review_comment.restaurant_id = @review.restaurant_id
    @review.review_comments << @review_comment

    if @review_comment.id.to_i > 0
      flash[:notice] = "You have added a comment on review - ##{@review.id}"
      redirect_to "#{restaurant_long_url(
          :name => @review.restaurant.name.parameterize.to_s,
          :id => @review.restaurant.id)}#review-#{@review.id}"
    else
      flash[:notice] = "Failed to add comment on review - ##{@review.id}"
      redirect_to "#{restaurant_long_url(
          :name => @review.restaurant.name.parameterize.to_s,
          :id => @review.restaurant.id)}#review-#{@review.id}" 
    end
  end

  def destroy
    @review_comment = ReviewComment.find(params[:id].to_i);

    if @review_comment.author?(current_user) && @review_comment.can_delete?
      if @review_comment.destroy
        flash[:notice] = 'Successfully removed your comment.'
      else
        flash[:notice] = 'Failed to remove your comment.'
      end
    else
      if !@review_comment.can_delete?
        flash[:notice] = 'Time up!, move your ass fast next time.<br/>btw, you could remove this comment <br/>within 10 minutes of the submission time.'
      else
        flash[:notice] = 'You are not authorized to perform this action.'
      end
    end

    redirect_to "#{restaurant_long_url(
          :name => @review_comment.restaurant.name.parameterize.to_s,
          :id => @review_comment.restaurant.id)}#review-#{@review_comment.review_id}"
  end
end
