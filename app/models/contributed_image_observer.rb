class ContributedImageObserver < ActiveRecord::Observer

  def after_create(contributed_image)
    if contributed_image.restaurant
      StuffEvent.create(
          :topic_id => contributed_image.topic_id,
          :restaurant_id => contributed_image.restaurant_id,
          :image_id => contributed_image.image_id,
          :user_id => contributed_image.user_id,
          :event_type => StuffEvent::TYPE_CONTRIBUTED_IMAGE)
    end
  end
end
