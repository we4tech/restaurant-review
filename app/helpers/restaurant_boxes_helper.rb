module RestaurantBoxesHelper

	# Render restaurant status in a short text.
  # ie, check ins (count), wanna go (count) etc...
  def render_restaurant_review_stats(p_restaurant, p_short = true)
    reviews   = p_restaurant.reviews
    variables = {
        :checkins_count => p_restaurant.checkins_count.to_i
    }

    if !reviews.empty?
      total_reviews_count = p_restaurant.reviews.count
      loved_count         = p_restaurant.reviews.loved.count
      loved_percentage    = (100 / total_reviews_count) * loved_count

      variables           = variables.merge({
                                                :total_reviews_count => total_reviews_count,
                                                :loved_count         => loved_count,
                                                :loved_percentage    => loved_percentage
                                            })
    end

    render :partial => 'restaurants/parts/review_stats.html.erb', :locals => variables
  end

  def render_restaurant_review_stats_by_user(user, restaurant, visible_field = :checkins)
    variables = {:user => user, :restaurant => restaurant}

    case visible_field
      when :checkins
        variables[:checkins_count] = user.checkins.by_restaurant(restaurant.id).count

      when :reviews
        variables[:reviews_count] = user.reviews.by_restaurant(restaurant.id).count

      when :loves
        variables[:loves_count] = user.reviews.loved.by_restaurant(restaurant.id).count
    end

    render :partial => 'restaurants/parts/review_stats_by_user.html.erb', :locals => variables
  end  

  # Render a list of who have shown up interest to be the specific place.
  def render_who_wanna_go_there(restaurant_or_event, limit = 5)
    wanna_go_reviews = restaurant_or_event.reviews.by_topic(@topic.id).wanna_go.all(:limit => limit, :include => [:user])
    link_options     = {:id => restaurant_or_event.id, :name => url_escape(restaurant_or_event.name)}
    if restaurant_or_event.is_a?(TopicEvent)
      link_options[:mt] = :topic_event
    end

    render :partial => 'restaurants/parts/who_wanna_go_there', :locals => {
        :title     => 'Who wanna visit here!',
        :reviews   => wanna_go_reviews,
        :more_link => who_wanna_go_place_url(link_options)
    }
  end

  # Render tag cloud of the tags
  def render_tagcloud(p_config)
    bind_column = p_config['bind_column'].to_s
    field       = @topic.form_attribute.fields.reject { |h| h if h['field'] != bind_column }
    tag_names   = field.first ? (field.first['default_value'] || '').split('|') : []

    tags        = Tag.all(:conditions => {:name => tag_names, :topic_id => @topic.id})

    render :partial => 'restaurants/parts/tagcloud', :locals => {
        :config     => p_config,
        :tags       => tags,
        :tag_groups => TagGroup.all,
        :column     => bind_column.to_sym
    }
  end

  # Render the featured restaurant slider box
  def render_feature_restaurants_box(options = {})
    @top_rated_restaurants = Restaurant.featured(@topic.id)
    render :partial => 'restaurants/parts/featured_restaurants_for_mail'
  end

  # Render related restaurants list
  def render_related_restaurants(per_page = 5, options = {})
    restaurant = options[:restaurant] || @restaurant
    long_array         = (restaurant.long_array || []).collect { |l| l.downcase.sphinxify }
    short_array        = (restaurant.short_array || []).collect { |s| s.downcase.sphinxify }
    cuisine_tags       = TagGroup::separate_tags(:cuisins, long_array).collect(&:sphinxify)
    long_array         = long_array - cuisine_tags

    long_array_length  = long_array.length - 1 > 0 ? long_array.length - 1 : 1
    short_array_length = 1


    # first search with strict location and cuisines
    queries            = []
    # %{#{short_array.empty? ? '' : '@short_array '}#{short_array.join('|')} #{cuisine_tags.empty? ? '' : '@long_array '}#{cuisine_tags.join('|')} }.strip
    if !short_array.empty?
      queries << "@short_array #{short_array.join('|')}"
    end

    if !cuisine_tags.empty?
      queries << "@long_array #{cuisine_tags.join('|')}"
    end

    # TODO: Fix This module
    if not queries.empty?
      sphinxify_text = restaurant.name.sphinxify
      if !sphinxify_text.strip.blank?
        queries << "@name -(#{sphinxify_text})"
      end

      restaurants = perform_search([:Restaurant], (queries.join(' ')), {:per_page => per_page, :page => 1})
      restaurants.uniq!

      # second find without location filter
      if restaurants.empty? || restaurants.length < per_page
        queries = []
        # %{@long_array #{cuisine_tags.join('|')} @name -(#{restaurant.name})}
        if !cuisine_tags.empty?
          queries << "@long_array #{cuisine_tags.join('|')}"
          queries << "@name #{restaurant.name.sphinxify})"
        end

        more_restaurants = perform_search([:Restaurant], (queries.join(' ')), {:per_page => per_page, :page => 1})
        more_restaurants.uniq!
        more_restaurants.each do |r|
          restaurants << r
        end
      end

      if restaurants.empty? || restaurants.length < per_page
        queries = []
        # %{@long_array "#{cuisine_tags.join(' ')} #{long_array.join(' ')}"/1 @name -(#{restaurant.name})}
        if !cuisine_tags.empty?
          queries << "@long_array \"#{cuisine_tags.join('|')}"
        else
          queries << "@long_array \""
        end

        if !long_array.empty?
          queries << "#{long_array.join(' ')}\"/1"
        end

        queries << "@name -(#{restaurant.name.sphinxify})"

        restaurant_ids   = restaurants.collect(&:id)
        more_restaurants = perform_search([:Restaurant], (queries.join(' ')), {:per_page => 10, :page => 1})
        more_restaurants.uniq!
        more_restaurants.each do |r|
          if !restaurant_ids.include?(r.id)
            restaurants << r
          end
        end
      end

      restaurants.uniq!
      restaurants = restaurants[0..per_page]

      if !restaurants.empty?
        if !block_given?
          render :partial => 'restaurants/parts/lovable_places', :locals => {
                 :more_link   => false,
                 :config      => (options || {}).merge(:count => restaurants.length),
                 :restaurants => restaurants}
        else
          yield(restaurants)
        end
      end
    else
      ''
    end
  end

  # Render week top chart based on the following criteria
  #   1. Review of the week
  #   2. Who was the most active eater (Eat out leader box)
  #   2. Who was the most active contributor (Review leader box)
  def render_week_top_chart(now = Time.now)
    html                   = ''

    # 1. Determine the most lovable place
    week_hot               = Restaurant.hot_of_the_week(@topic, now)
    week_mostly_checked_in = Restaurant.hot_of_the_week(@topic, now, :checkin)

    if week_hot || week_mostly_checked_in
      html << '<h4 class="subHeaderWithIcon">Top of the week</h4>'
    end

    if week_hot
      html << render(:partial => 'restaurants/parts/week_hot.html.erb', :locals => {:restaurant => week_hot})
      html << content_tag('div', '', :class => 'space_10')
    end

    if week_mostly_checked_in
      if !html.blank?
        html << '<div class="break"></div>'
      end

      html << render(:partial => 'restaurants/parts/week_hot_checkin.html.erb', :locals => {:restaurant => week_mostly_checked_in})
      html << content_tag('div', '', :class => 'space_10')
    end

    html
  end

  def render_address_in_map(restaurant, options = {})
    just_map = options[:just_map] || false
    
    if restaurant.located_in_map?
      map_url      = "http://maps.google.com/maps/api/staticmap?center=" +
          "#{restaurant.lat},#{restaurant.lng}&zoom=13&" +
          "sensor=false&markers=color:green|label:R|" +
          "#{restaurant.lat},#{restaurant.lng}&key=#{@topic.gmap_key.blank? ? MAP_API_KEY : @topic.gmap_key}&size="
      details_link = "http://maps.google.com/maps?f=q&" +
          "q=#{CGI.escape(restaurant.address)}&hl=en&" +
          "geocode=&sll=#{restaurant.lat},#{restaurant.lng}"

      render :partial => 'restaurants/parts/address',
             :locals  => {:map_url => map_url, :details_link => details_link, :restaurant => restaurant, :just_map => just_map}
    end
  end

  def render_restaurant_status(restaurant)
    checkins_count = restaurant.checkins.count rescue 0
    reviews_count  = restaurant.reviews.count rescue 0
    loves_count    = restaurant.reviews.loved.count rescue 0

    %{
    <div class='restaurantStatus'>
      <div class="block blockBorder">
        <div class="label">CHECK-INS</div>
        <div class="value">#{checkins_count}</div>
      </div>
      <div class="block blockBorder">
        <div class="label">REVIEWS</div>
        <div class="value">#{reviews_count}</div>
      </div>
      <div class="block">
        <div class="label">LOVES</div>
        <div class="value">#{loves_count}</div>
      </div>
      <div class='clear'></div>
    </div>
    }
  end

  def render_restaurant_status_in_graph(restaurant)
    checkins_count = restaurant.checkins.count rescue 0
    reviews_count  = restaurant.reviews.count rescue 0
    loves_count    = restaurant.reviews.loved.count rescue 0
    total          = (checkins_count + reviews_count + loves_count).to_f
    values         = [reviews_count.to_f, loves_count.to_f, checkins_count.to_f].join(',')
    link           = "http://chart.apis.google.com/chart?chs=150x145&cht=p&chco=80C65A|FF3366|76A4FB&chds=a&chd=t0:#{values}&chdl=Reviews|Loves|Check-ins&chdlp=t&chp=20&chma=2|0,14"

    image_tag(link)
  end
  
  #
  # Look for users which has just checked in (or about 30 mins to 1 hour ago)
  def render_online_users(restaurant, limit, options = {})
    checkins = restaurant.checkins.with_in(2.hours)

    if checkins.present?
      users = checkins.collect(&:user)
      render :partial => 'users/parts/users', :locals => { 
        :quote => "#{users.count} people have checked in this place with in last 2 hours.",
        :users => users, 
        :label => "#{users.count} #{users.count == 1 ? 'person' : 'people'} just checked in"
      }
    end
  end 
  
end