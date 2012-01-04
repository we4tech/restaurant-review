class CheckinsController < ApplicationController

  before_filter :login_required

  def create
    if duplicate_checkin
      flash[:notice] = 'You have already checked in this place.'
      redirect_to :back
      return
    end

    saved = false
    o = nil
    checkin = nil

    case params[:topic_name]
      when 'restaurant'
        o = Restaurant.find(params[:id])
        saved, checkin = create_check_in({:restaurant_id => o.id})

      when 'topic-event'
        o = TopicEvent.find(params[:id])
        saved, checkin = create_check_in({:topic_event_id => o.id})
    end

    if saved
      flash[:notice] = "Great! you have just checked in - #{o.name}"
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url('checkedin', o.id, :checkin_id => checkin.id, :next_to => event_or_restaurant_url(o))
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
    def duplicate_checkin
      record_id = params[:id]
      checkin = nil

      if params[:topic_name] == 'restaurant'
        checkin = checkin_record(record_id, {:restaurant_id => record_id})
      elsif params[:topic_name] == 'topic_event'
        checkin = checkin_record(record_id, {:topic_event_id => record_id})
      end

      if checkin.nil? || Time.now > (checkin.created_at + 2.hours)
        false
      else
        true
      end
    end

    def checkin_record(record_id, attributes)
      Checkin.last(:conditions => {:user_id => current_user.id, :topic_id => @topic.id}.merge(attributes))
    end

    def create_check_in(attrbutes)
      checkin = Checkin.create(
          {
              :user_id => current_user.id,
              :topic_id => @topic.id
          
          }.merge(attrbutes)
      )

      [checkin && checkin.id > 0, checkin]
    end
end
