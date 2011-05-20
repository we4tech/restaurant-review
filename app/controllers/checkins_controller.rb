class CheckinsController < ApplicationController

  before_filter :login_required

  def create
    saved = false
    o = nil

    case params[:topic_name]
      when 'restaurant'
        o = Restaurant.find(params[:id])
        saved = create_check_in({:restaurant_id => o.id})

      when 'topic_event'
        o = TopicEvent.find(params[:id])
        saved = create_check_in({:topic_event_id => o.id})
    end

    if saved
      flash[:notice] = "Great! you have just checked in - #{o.name}"
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url('checkedin', o.id, :next_to => event_or_restaurant_url(o))
        return
      end
    else
      flash[:notice] = "Failed to check you in - #{o.name}"
    end

    redirect_to event_or_restaurant_url(o)
  end

  def index
    @checkins = []
    if params[:restaurant_id]
      @restaurant = Restaurant.find(params[:restaurant_id])
      @checkins = @restaurant.checkins.paginate(:page => params[:page])
    else
      @checkins = Checkin.all.paginate(:page => params[:page])
    end

    respond_to do |format|
      format.mobile {
        render :layout => false
      }
    end
  end

  private
    def create_check_in(attrbutes)
      checkin = Checkin.create(
          {
              :user_id => current_user.id,
              :topic_id => @topic.id
          
          }.merge(attrbutes)
      )

      checkin && checkin.id > 0
    end
end
