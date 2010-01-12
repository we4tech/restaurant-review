class RestaurantObserver < ActiveRecord::Observer

  def after_create(restaurant)
    StuffEvent.create(
        :topic_id => restaurant.topic_id,
        :restaurant_id => restaurant.id,
        :user_id => restaurant.user_id,
        :event_type => StuffEvent::TYPE_RESTAURANT)
  end

  def after_update(restaurant)
    StuffEvent.create(
        :topic_id => restaurant.topic_id,
        :restaurant_id => restaurant.id,
        :user_id => restaurant.user_id,
        :event_type => StuffEvent::TYPE_RESTAURANT_UPDATE)
  end
end
