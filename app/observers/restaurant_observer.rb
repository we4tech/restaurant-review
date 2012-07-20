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
        o = find_or_create_tag(tag, restaurant.topic_id)
        existing_tags << o.name
      end
      restaurant.__send__("#{field_name}=".to_sym, existing_tags)
    end
  end

  def after_validation(restaurant)
    if !restaurant.errors.empty?
      (restaurant.new_tags || {}).each do |field_name, new_tags|
        existing_tags = restaurant.__send__(field_name.to_sym) || []
        new_tags.each do |tag|
          parts = tag.split('|')
          if existing_tags.include?(parts.first)
            existing_tags.delete(parts.first)
          end
        end
      end
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
      mapped_tags = []

      if !tags.empty?
        # Iterate each tag
        tags.each do |tag|
          tag.strip!
          # Find existing tag Or create new tag
          tag_object = find_or_create_tag(tag, restaurant.topic_id)

          # Create new map
          map_tag_with(tag_object, restaurant)
          mapped_tags << tag_object.name
        end
      end

      mapped_tags
    end

    def map_tag_with(tag_object, restaurant)
      TagMapping.create(
          :tag_id => tag_object.id,
          :restaurant_id => restaurant.id,
          :user_id => restaurant.user_id,
          :topic_id => restaurant.topic_id)
    end

    def find_or_create_tag(tag, topic_id)
      tag_group_id = 0

      if tag.match(/\|\d+/)
        parts = tag.split('|')
        tag = parts.first
        tag_group_id = parts.last.to_i
      end

      o = Tag.find_or_create_by_name_and_topic_id(tag, topic_id)
      if tag_group_id > 0
        TagGroupMapping.create(
            :tag_id => o.id,
            :topic_id => topic_id,
            :tag_group_id => tag_group_id
        )
      end
      o
    end
end
