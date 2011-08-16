module UrlOverrideHelper

  include PremiumHelper 

  def user_long_url(p_options)
    if p_options.is_a?(User)
      user = p_options
      # IMPORTANT: Empty login will lead to user_long_route instead topic preference
      if @topic.user_subdomain? && !user.login.blank? && !user.login.match(/ajax|asset/i)
        root_url :subdomain => user.domain_name
      else
        user_long_route_url(:login => url_escape(user.login && !user.login.blank? ? user.login : 'fb_user'),
                            :id => user.id)
      end
    else
      p_options[:login] = p_options[:login] && !p_options[:login].blank? ? p_options[:login] : 'fb_user'
      user_long_route_url(p_options)
    end
  end

  alias :user_long_path :user_long_url


  def user_link(user, options = {})
    same_user_check = options[:same_user_check]
    length = options[:length] || -1

    user_name = user.login.humanize

    if same_user_check
      if user.id == same_user_check.id
        user_name = 'Own'
      end
    end

    if length.to_i > 0
      user_name = user_name[0..(length - 1)]
    end

    link_to user_name, user_long_url(user)
  end

  def user_display_picture(user, options = {})
    link_to image_tag(user.display_picture), user_long_url(user)
  end

  def restaurant_long_url(p_options, options2 = {})
    topic = options2.delete(:topic)
    topic = @topic if topic.nil?
    topic = (p_options.is_a?(Restaurant) ? p_options.topic : nil) if topic.nil?
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

  def restaurant_link(restaurant, options = {})
    length = options.delete(:length)
    link_to length ? truncate(restaurant.name, length) : restaurant.name, restaurant_long_url(restaurant)
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

  #
  # Generate fragmented html ajax requesting URL
  # this is based on +fragment_for_route+ route with little bit more and
  # advance feature such as multi domain supports.
  #
  # by default this feature is intended to use the current request domain
  # stripping left most domain and replacing that position
  # with ajax0 to ajax2 domain name.
  # so we could take advantages of having 2X3 = 6 concurrent browser
  # connection threads available for serving our request.
  #
  # Parameters -
  #   - fragment_key - this is used for handling the specific fragmented response
  #   - options -      {:dynamic_ajax_host => true | [false]}
  #
  def _fragment_for_path(fragment_key, options = {})
    host = request.host

    if options[:dynamic_ajax_host].nil? || options[:dynamic_ajax_host]
      host = determine_dynamic_ajax_host(host, 3)
    end

    if options[:__topic_id].nil?
      options[:__topic_id] = @topic.id
    end

    fragment_for_route_url(fragment_key, options.merge(:host => host))
  end

  alias :_fragment_for_url :_fragment_for_path

  DEFAULT_OPTIONS = {
      :subdomain_name => 'ajax',
      :max_subdomains => 3
  }

  #
  # Wrap the specified url route with the ajax prefixed domain,
  #
  # Parameters -
  #   - subdomain_name  - (default ajax) override default sub domain name
  #   - max_subdomains - (default 3) override number of sub domain factor
  #     through the options map
  #
  def ajaxified_url_wrap(route, route_options = {})
    options = DEFAULT_OPTIONS.merge(route_options)
    host = determine_dynamic_ajax_host(
        request.host, options.delete(:max_subdomains),
        options.delete(:subdomain_name))
    required_options = {:host => host, :__topic_id => @topic.id}

    # Force user defined host if specified through route_options
    required_options[:host] = route_options[:host] if route_options[:host]
    send(route, route_options.merge(required_options))
  end

  def tag_search_url(tag)
    search_url('name|short_array|long_array|description' => tag.name,
               '_models' => 'Restaurant')
  end

  def event_long_url(event, options = {})
    event_long_route_url({:name => URI.escape(url_escape(event.name)), :id => event.id}.merge(options))
  end

  def event_link(event, options = {})
    length = options.delete(:length)
    link_to (length ? truncate(event.name, length) : event.name), event_long_url(event, options)
  end

  def section_url(section, tag = false)
    group_name = section.tag_groups.empty? ? (tag ? 'tag' : 'sections') : section.tag_groups.first.name
    tag_details_url(url_escape(group_name), :tag => url_escape(section.name))
  end

  #
  # Return url for either event home page or restaurant home page based
  # on specified model type
  def event_or_restaurant_url(model_instance, options = {})
    case model_instance
      when Restaurant
        restaurant_long_url(model_instance, options)
      when TopicEvent
        event_long_url(model_instance, options)
      else
        nil
    end
  end

  #
  # Return a HTML anchor tag either for the event or restaurant based
  # on the object type
  def event_or_restaurant_link(model_instance)
    link_to model_instance.name, event_or_restaurant_url(model_instance)
  end

  #
  # Determine site root url based on the specific topic, either select
  # default site root or select event's page root.
  def root_or_specific_root_url(model_instance)
    case model_instance
      when TopicEvent
        events_url
      else
        root_url
    end
  end

  private
    @@current_ajaxified_url_index = 0

    def determine_dynamic_ajax_host(host, max_hosts, subdomain_name = 'ajax')
      ajax_host = "#{subdomain_name}#{@@current_ajaxified_url_index}"
      @@current_ajaxified_url_index += 1
      @@current_ajaxified_url_index = 0 if @@current_ajaxified_url_index > max_hosts
      host_parts = host.split('.')
      "#{ajax_host}.#{host_parts[host_parts.length - 2, host_parts.length].join('.')}#{request.port != 80 ? ":#{request.port}" : ''}"
    end

end
