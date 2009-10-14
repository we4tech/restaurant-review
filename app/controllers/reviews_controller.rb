class ReviewsController < ApplicationController

  def create
    @review = Review.new(params[:review])
    @review.user_id = current_user.id

    if @review.save
      flash[:notice] = 'Successfully added your review!'
    else
      flash[:notice] = 'Failed to add your review!'
    end

    redirect_to :back
  end

  def update
    @review = Review.find(params[:id].to_i)
    if @review.update_attributes(params[:review])
      flash[:notice] = 'Successfully updated your review!'
    else
      flash[:notice] = 'Failed to update your review!'
    end

    redirect_to :back
  end

end
