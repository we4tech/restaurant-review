class ReviewsController < ApplicationController

  before_filter :login_required
  

  def create
    @review = Review.new(params[:review])
    @review.user_id = current_user.id
    @review.topic_id = @topic.id

    if @review.save
      flash[:notice] = 'Successfully added your review!'
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url(
            'new_review', @review.id,
            :next_to => restaurant_long_url(
                :id => @review.restaurant.id,
                :name => url_escape(@review.restaurant.name),
                :page => :reviews))
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
    attributes = (params[:review] || {}).merge(
        :user_id => current_user.id,
        :topic_id => @topic.id)

    if @review.update_attributes(attributes)
      flash[:notice] = 'Successfully updated your review!'
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url(
            'updated_review', @review.id,
            :next_to => restaurant_long_url(
                :id => @review.restaurant.id,
                :name => url_escape(@review.restaurant.name),
                :page => :reviews))
      else
        redirect_to :back
      end
    else
      flash[:notice] = 'Failed to update your review!'
      redirect_to :back
    end
  end

  def index
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @site_title = 'Reviews'
    render_view('reviews/index')
  end

end
