module RestaurantsHelper

  #
  # Render a subset restaurants based on provided filters.
  def render_short_list(filters, options = {})
    if filters && filters.present?
      model_chain = Restaurant

      filters.each do |field, value|
        model_chain.add_filter(field, single_or_multiple_value(value))
      end

      model_chain.all({:limit => 5, :offset => 0}.merge(options))
    else
      Restaurant.all({:limit => 5, :offset => 0}.merge(options))
    end
  end

  def single_or_multiple_value(value)
    if value.is_a?(Array)
      value
    else
      [value].compact
    end
  end

  # Render most loved places through the whole history
  def render_most_lovable_places(p_config, p_limit = 5)
    # MojarQuery.Builder.new.retrieve.only(5).restaurants
    #         .sort_by.reviews.with_conditions(:type => 'loved').count
    #
    config = p_config || {}
    filters = config[:filters]
    users = []

    if filters && filters[:users]
      users = filters[:users]
    end

    if users.empty?
      render :partial => 'restaurants/parts/lovable_places', :locals => {
          :more_link   => most_loved_places_url,
          :config      => p_config,
          :restaurants => Restaurant.most_loved(@topic, p_limit)}
    else
      render :partial => 'restaurants/parts/lovable_places', :locals => {
          :more_link   => most_loved_places_url('filters[user_id]' => users.collect(&:id).join('|')),
          :config      => p_config,
          :restaurants => Restaurant.most_loved_by_users(@topic, users, p_limit)}
    end
  end

  # Render the most checkined places
  def render_most_checkined_places(p_config, p_limit = 5)
    #
    # MojarQuery.Builder.new.retrieve.only(5).restaurants
    #         .sort_by.checkins.count
    #
    #
    config = p_config || {}
    filters = config[:filters]
    users = []

    if filters && filters[:users]
      users = filters[:users]
    end

    if users.empty?
      render :partial => 'restaurants/parts/lovable_places', :locals => {
          :more_link   => most_checkedin_places_url,
          :config      => p_config,
          :restaurants => Restaurant.most_checkined(@topic, p_limit, 0)}
    else
      render :partial => 'restaurants/parts/lovable_places', :locals => {
          :more_link   => most_checkedin_places_url('filters[user_id]' => users.collect(&:id).join('|')),
          :config      => p_config,
          :restaurants => Restaurant.most_checkined_by_users(@topic, users, p_limit, 0)}
    end
  end


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

  # Render list of recently reviewed places
  def render_recently_reviewed_places(p_config, p_limit = 10)
    config = p_config || {}
    filters = config[:filters]
    users = []

    if filters && filters[:users]
      users = filters[:users]
    end

    if users.empty?
      render :partial => 'restaurants/parts/recently_reviewed_places', :locals => {
          :config    => p_config,
          :more_link => recently_reviewed_places_url,
          :reviews   => Review.recent.by_topic(@topic.id).all(
              :include    => [:restaurant], :limit => p_limit,
              :conditions => ['reviews.comment <> ""'])}
    else
      render :partial => 'restaurants/parts/recently_reviewed_places', :locals => {
        :config    => p_config,
        :more_link => recently_reviewed_places_url('filters[user_id]' => users.collect(&:id).join('|')),
        :reviews   => Review.recent.by_topic(@topic.id).by_users(users).all(
            :include    => [:restaurant], :limit => p_limit,
            :conditions => ['reviews.comment <> ""'])}
    end
  end

  # Render list of recently added places
  def render_recently_added_places(p_config, p_limit = 10)
    config = p_config || {}
    filters = config[:filters]
    users = []

    if filters && filters[:users]
      users = filters[:users]
    end

    if users.empty?
      render :partial => 'restaurants/parts/lovable_places', :locals => {
          :config      => p_config,
          :more_link   => recent_places_url,
          :restaurants => Restaurant.recent.by_topic(@topic.id).all(:limit => p_limit)}
    else
      render :partial => 'restaurants/parts/lovable_places', :locals => {
          :config      => p_config,
          :more_link   => recent_places_url('filters[user_id]' => users.collect(&:id).join('|')),
          :restaurants => Restaurant.recent.by_topic(@topic.id).by_users(users).all(:limit => p_limit)}
    end
  end

  # Render list of recently uploaded pictures
  def render_recently_added_pictures(p_limit = 5)
    render :partial => 'restaurants/parts/recently_added_pictures', :locals => {
        :title       => 'Recently added pictures!',
        :more_link   => recently_reviewed_places_url,
        :restaurants => Restaurant.recently_added_pictures(p_limit)}
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

  def render_address_in_map(restaurant)
    if restaurant.located_in_map?
      map_url      = "http://maps.google.com/maps/api/staticmap?center=" +
          "#{restaurant.lat},#{restaurant.lng}&zoom=13&" +
          "sensor=false&markers=color:green|label:R|" +
          "#{restaurant.lat},#{restaurant.lng}&key=#{@topic.gmap_key.blank? ? MAP_API_KEY : @topic.gmap_key}&size="
      details_link = "http://maps.google.com/maps?f=q&" +
          "q=#{CGI.escape(restaurant.address)}&hl=en&" +
          "geocode=&sll=#{restaurant.lat},#{restaurant.lng}"

      render :partial => 'restaurants/parts/address',
             :locals  => {:map_url => map_url, :details_link => details_link, :restaurant => restaurant}
    end
  end

  def render_if_owner_contact(restaurant)
    %{
    <a href='mailto:biz@welltreat.us?subject=[BIZ knock knock] About ##{restaurant.id} #{restaurant.name.gsub(/'/, '')}'
       title="#{t('title.own_this')}">
      #{image_tag('fresh/button_do_u_own_this.png')}
    </a>
    }
  end

  def render_properties(restaurant)
    content_tag 'div', :class => 'properties' do
      html            = ''
      excluded_fields = ['long_array', 'name', 'description', 'address']
      excluded_labels = []

      @form_fields.each do |field|
        field_label = field['label']
        field_name  = field['field']
        field_type  = field['type']
        display     = field['display']
        field_value = field_name ? @restaurant.send(field_name) : nil


        if !field_value.blank? && display && !excluded_fields.include?(field_name.to_s) &&
            !excluded_labels.include?(field_label.to_s)
          html << content_tag('div', field_label, :class => "grid_1 key #{url_escape(field_label)}")
          html << content_tag('div', format_content(field_type, field_value), :class => 'grid_3 value')
        end
      end

      html << content_tag('div', '', :class =>'clear')
      html << content_tag('div', '', :class =>'space_5')
      html
    end
  end

  def format_content(type, value)
    case type
      when 'checkbox'
        value == true ? 'yes' : 'no'

      when 'options'
        (value || []).collect { |t| link_to(t, section_url(t)) }.join(', ')

      else
        safe_textilize(value)
    end
  end

  def render_restaurant_status(restaurant)
    checkins_count = restaurant.checkins.count
    reviews_count  = restaurant.reviews.count
    loves_count    = restaurant.reviews.loved.count

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
    checkins_count = restaurant.checkins.count
    reviews_count  = restaurant.reviews.count
    loves_count    = restaurant.reviews.loved.count
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
  
  #
  # Render list of users who wanna go there.
  def render_wanna_go(restaurant, limit, options = {})
    count = restaurant.reviews.wanna_go.count
    
    if count > 0
      render :partial => 'users/parts/users', :locals => {
        :users => restaurant.reviews.wanna_go.collect(&:user),
        :label => "#{count} #{count == 1 ? 'person' : 'people'} wanna visit here"
      }
    end
  end
    
end
