module UrlOverrideHelper

  include PremiumHelper 

  def user_long_url(p_options)
    if p_options.is_a?(User)
      user = p_options
      user_long_route_url(:login => url_escape(user.login && !user.login.blank? ? user.login : 'fb_user'),
                          :id => user.id)
    else
      p_options[:login] = p_options[:login] && !p_options[:login].blank? ? p_options[:login] : 'fb_user'
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

    if p_options.is_a?(Restaurant)
      options[:id] = restaurant.id

      if premium?
        premium_restaurant_url(options.merge(options2))
      else
        options[:name] = url_escape(restaurant.name)
        restaurant_long_route_url(options.merge(options2))
      end
    else
      if premium?
        premium_restaurant_url(options.merge(options2))
      else
        restaurant_long_route_url(options.merge(options2))
      end
    end
  end

  def restaurant_link(restaurant)
    link_to restaurant.name, restaurant_long_url(restaurant)
  end

  def discover_url(object)
    
  end

  def site_products_url(restaurant)
    if premium? && pt_activate_no_reference_url?
      products_url
    else
      restaurant_products_url(restaurant)
    end
  end

  def site_product_url(product)
    if premium? && pt_activate_no_reference_url?
      product_long_url(url_escape(product.name), product.id)
    else
      restaurant_product_url(product.restaurant, product)
    end
  end

  def site_product_link(product)
    link_to product.name, site_product_url(product)
  end

  def pt_site_reviews
    if premium? && pt_activate_no_reference_url?
      site_reviews_url
    else
      restaurant_reviews_url(@restaurant)
    end
  end

  def attached_url(model, object)
    case model
      when 'product'
        site_product_url(object)
      else
        nil
    end
  end

  def attached_link(model, object)
    link_to object.name, attached_url(model, object)
  end

end
