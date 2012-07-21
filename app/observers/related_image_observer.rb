class RelatedImageObserver < ActiveRecord::Observer

  def after_create(related_image)
    if related_image.restaurant
      StuffEvent.create(
          :topic_id => related_image.topic_id,
          :restaurant_id => related_image.restaurant_id,
          :image_id => related_image.image_id,
          :user_id => related_image.user_id,
          :event_type => StuffEvent::TYPE_RELATED_IMAGE)
    end
  end

end
