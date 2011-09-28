class PhotoCommentObserver < ActiveRecord::Observer

  def after_create(comment)
    StuffEvent.create({
        :topic_id => comment.any.topic_id,
        :user_id => comment.user_id,
        :image_id => comment.image_id,
        :review_id => comment.id,
        :event_type => StuffEvent::TYPE_PHOTO_COMMENT
    }.merge(comment.map_any))
  end

  def after_destroy(comment)
    event = StuffEvent.first(
        :conditions => {
            :topic_id => comment.any.topic_id,
            :image_id => comment.image_id,
            :user_id => comment.user_id,
            :review_id => comment.id
        }
    )
    event.destroy if event
  end
end
