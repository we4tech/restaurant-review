module UrlOverrideHelper

  def user_long_url(p_options)
    if p_options.is_a?(User)
      user = p_options
      user_long_route_url(:login => url_escape(user.login),
                          :id => user.id)
    else
      user_long_route_url(p_options)
    end
  end

  def user_link(user)
    link_to user.login.humanize, user_long_url(user)
  end

  def restaurant_long_url(p_options, options2 = {})
    topic = @topic
    topic = Topic.default if topic.nil?

    options = p_options.is_a?(Restaurant) ? {} : p_options
    options[:topic_name] = topic.name.pluralize

    restaurant_id = p_options.is_a?(Restaurant) ? p_options.id : p_options[:id]
    restaurant = p_options.is_a?(Restaurant) ? p_options : Restaurant.find(restaurant_id)

    if !restaurant.premium? || options[:d] || options2[:d] || params[:d]
      if p_options.is_a?(Restaurant)
        options[:id] = restaurant.id
        options[:name] = url_escape(restaurant.name)
        restaurant_long_route_url(options.merge(options2))
      else
        restaurant_long_route_url(options.merge(options2))
      end

    else
      case options[:page]
        when :reviews
          restaurant_reviews_url(restaurant_id, options2)

        when :news
          restaurant_message_url(restaurant_id, options2)

        when :food_items
          restaurant_food_item_url(restaurant_id, options2)

        else
          premium_restaurant_url(restaurant_id, options2)
      end
    end
  end

  def restaurant_link(restaurant)
    link_to restaurant.name, restaurant_long_url(restaurant)
  end

  def discover_url(object)
    
  end
end
