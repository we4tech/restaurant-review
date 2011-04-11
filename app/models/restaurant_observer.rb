class RestaurantObserver < ActiveRecord::Observer

  def before_save(restaurant)
    restaurant.long_array = (restaurant.long_array || []).collect{|t| t.strip if t}.compact
    restaurant.short_array = (restaurant.short_array || []).collect{|t| t.strip if t}.compact
  end

  def after_create(restaurant)
    create_stuff_event(restaurant, StuffEvent::TYPE_RESTAURANT)
    store_tags(restaurant)
  end

  def before_validation(restaurant)
    (restaurant.new_tags || {}).each do |field_name, new_tags|
      existing_tags = restaurant.__send__(field_name.to_sym) || []
      new_tags.each do |tag|
         existing_tags << tag
      end
      restaurant.__send__("#{field_name}=".to_sym, existing_tags)
    end

  end

  def after_update(restaurant)
    create_stuff_event(restaurant, StuffEvent::TYPE_RESTAURANT_UPDATE)
    remove_tags(restaurant)
    store_tags(restaurant)
  end

  private
    def create_stuff_event(restaurant, event_type)
      StuffEvent.create(
        :topic_id => restaurant.topic_id,
        :restaurant_id => restaurant.id,
        :user_id => restaurant.user_id,
        :event_type => event_type)
    end

    def remove_tags(restaurant)
      tag_mappings = TagMapping.all(
          :conditions => {
              :user_id => restaurant.user_id,
              :topic_id => restaurant.topic_id,
              :restaurant_id => restaurant.id})
      tag_mappings.each{|tm| tm.destroy}
    end

    def store_tags(restaurant)
      # only applicable for long & short array fields
      tags1 = (restaurant.long_array || []).compact
      process_tags(tags1, restaurant)

      tags2 = (restaurant.short_array || []).compact
      process_tags(tags2, restaurant)
    end

    def process_tags(tags, restaurant)
      if !tags.empty?
        # Iterate each tag
        tags.each do |tag|
          tag.strip!
          # Find existing tag Or create new tag
          tag_object = find_or_create_tag(tag, restaurant.topic_id)

          # Create new map
          map_tag_with(tag_object, restaurant)
        end
      end
    end

    def map_tag_with(tag_object, restaurant)
      TagMapping.create(
          :tag_id => tag_object.id,
          :restaurant_id => restaurant.id,
          :user_id => restaurant.user_id,
          :topic_id => restaurant.topic_id)
    end

    def find_or_create_tag(tag, topic_id)
      Tag.find_or_create_by_name_and_topic_id(tag, topic_id)
    end
end
