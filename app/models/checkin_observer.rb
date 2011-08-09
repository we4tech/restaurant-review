class CheckinObserver < ActiveRecord::Observer

  def after_create(checkin)
    StuffEvent.create(
        :topic_id => checkin.topic_id,
        :restaurant_id => checkin.restaurant_id,
        :topic_event_id => checkin.topic_event_id,
        :user_id => checkin.user_id,
        :event_type => StuffEvent::TYPE_CHECKIN)
  end

end
