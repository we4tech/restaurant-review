module UrlOverrideHelper

  def restaurant_long_url(p_options)
    topic = @topic
    topic = Topic.default if topic.nil?

    options = p_options.is_a?(Restaurant) ? {} : p_options
    options[:topic_name] = topic.name.pluralize

    restaurant_id = p_options.is_a?(Restaurant) ? p_options.id : p_options[:id]
    restaurant = p_options.is_a?(Restaurant) ? p_options : Restaurant.find(restaurant_id)

    if !restaurant.premium? || !options[:d]
      if p_options.is_a?(Restaurant)
        options[:id] = restaurant.id
        options[:name] = url_escape(restaurant.name)
        restaurant_long_route_url(options)
      else
        restaurant_long_route_url(options)
      end

    else
      case options[:page]
        when :reviews
          restaurant_reviews_url(restaurant_id)

        when :news
          restaurant_message_url(restaurant_id)

        when :food_items
          restaurant_food_item_url(restaurant_id)

        else
          premium_restaurant_url(restaurant_id)
      end
    end
  end

  def discover_url(object)
    
  end
end
