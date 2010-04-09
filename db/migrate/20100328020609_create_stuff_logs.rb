class CreateStuffLogs < ActiveRecord::Migration

  def self.up
    # Fix user ownership related problem
    ContributedImage.all.each do |ci|
      if ci.restaurant && ci.image
        ci.update_attribute(:user_id, ci.image.user_id)
      end
    end

    ContributedImage.all.each do |ci|
      if ci.restaurant && ci.image
        StuffEvent.create(
            :topic_id => ci.topic_id,
            :restaurant_id => ci.restaurant_id,
            :image_id => ci.image_id,
            :user_id => ci.restaurant.user_id,
            :created_at => ci.created_at,
            :event_type => StuffEvent::TYPE_CONTRIBUTED_IMAGE)
      end
    end

    RelatedImage.all.each do |ri|
      if ri.restaurant && ri.image
        StuffEvent.create(
            :topic_id => ri.topic_id,
            :restaurant_id => ri.restaurant_id,
            :image_id => ri.image_id,
            :user_id => ri.user_id || ri.image.user_id,
            :created_at => ri.created_at,
            :event_type => StuffEvent::TYPE_RELATED_IMAGE)
      end
    end
  end

  def self.down
    StuffEvent.all(:conditions => {
        :event_type => [
            StuffEvent::TYPE_RELATED_IMAGE,
            StuffEvent::TYPE_CONTRIBUTED_IMAGE
        ]
    }).each{|se| se.destroy}
  end
end
