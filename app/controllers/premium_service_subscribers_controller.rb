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
        pt_redirect_to_root
      else
        flash[:notice] = 'Error found during subscribing your email address!'
        pt_render_template 'coming_soon'
      end

    else
      flash[:notice] = 'Invalid request!'
      redirect_to :back
    end
  end
end
