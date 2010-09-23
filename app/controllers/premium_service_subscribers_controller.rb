class PremiumServiceSubscribersController < ApplicationController

  def create
    @premium_service_subscriber = PremiumServiceSubscriber.new(params[:premium_service_subscriber])
    @restaurant = @premium_service_subscriber.restaurant

    if @restaurant
      @premium_template = @restaurant.selected_premium_template
      @topic = @restaurant.topic
      @context = :coming_soon

      if @premium_service_subscriber.save
        flash[:success] = 'You have subscribed successfully!'
        redirect_to coming_soon_restaurant_path(@restaurant.id)
      else
        pt_render_template 'coming_soon'
        flash[:notice] = 'Error found during subscribing your email address!'
      end

    else
      flash[:notice] = 'Invalid request!'
      redirect_to :back
    end
  end
end
