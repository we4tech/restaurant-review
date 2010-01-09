class ReviewsController < ApplicationController

  before_filter :login_required 

  def create
    @review = Review.new(params[:review])
    @review.user_id = current_user.id
    @review.topic_id = @topic.id

    if @review.save
      flash[:notice] = 'Successfully added your review!'
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url('new_review', @review.id, :next_to => restaurant_url(@review.restaurant_id))
      else
        redirect_to :back
      end
    else
      flash[:notice] = 'Failed to add your review!'
      redirect_to :back
    end
  end

  def update
    @review = Review.find(params[:id].to_i)
    if @review.update_attributes(params[:review])
      @review.update_attributes(:user_id => current_user.id, :topic_id => @topic.id)
      flash[:notice] = 'Successfully updated your review!'
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url('updated_review', @review.id, :next_to => restaurant_url(@review.restaurant_id))
      else
        redirect_to :back
      end
    else
      flash[:notice] = 'Failed to update your review!'
      redirect_to :back
    end
  end

end
