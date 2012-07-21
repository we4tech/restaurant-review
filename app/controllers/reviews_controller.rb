class ReviewsController < ApplicationController

  before_filter :login_required, :except => [:index, :create]

  def create
    ReviewService.
        create_from_params(@topic, params[:review]).
        subscribe(self).create
  end

  def update
    @review    = Review.find(params[:id].to_i)
    attributes = (params[:review] || { }).merge(
        :user_id  => current_user.id,
        :topic_id => @topic.id)

    if @review.author?(current_user) && @review.update_attributes(attributes)
      flash[:notice] = 'Successfully updated your review!'
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url(
                        'updated_review', @review.id,
                        :next_to => restaurant_long_url(@review.any))
      else
        redirect_to :back
      end
    else
      flash[:notice] = 'Failed to update your review!'
      redirect_to :back
    end
  end

  def index
    @restaurant = @restaurant || Restaurant.find(params[:restaurant_id].to_i)
    @site_title = 'Reviews'
    render_view('reviews/index')
  end

  def destroy
    review = Review.find(params[:id])
    if review.author?(current_user)
      if review.destroy
        notify :success, :back
      else
        notify :failure, :back
      end
    else
      flash[:notice] = 'You are not allowed'
      redirect_to :back
    end
  end

  private
    def after_successfully_created(context)
      @review = context.review

      flash[:notice] = 'Successfully added your review!'
      redirect_url   = event_or_restaurant_url(@review.any)

      if current_user.share_on_facebook?
        redirect_to facebook_publish_url(
                        'new_review', @review.id,
                        :next_to => "#{redirect_url}#review-#{@review.id}")
      else
        redirect_to "#{redirect_url}#review-#{@review.id}"
      end
    end

    def after_failed_to_create(context)
      @review = context.review

      if @review.present?
        flash[:notice] = "Failed: #{@review.errors.full_messages.join('<br/>')}."
      elsif context.user.nil?
        flash[:notice] = "Failed to create review due to invalid user or login information."
      else
        flash[:notice] = 'Failed to create review.'
      end

      redirect_to :back
    end

    def after_user_signed_in(context, user)
      self.current_user = user
      user.log_it!(request.env["HTTP_X_FORWARDED_FOR"] || request.remote_addr)

      # Always remember current login
      handle_remember_cookie! true
    end

end
