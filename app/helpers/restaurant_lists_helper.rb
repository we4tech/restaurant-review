module RestaurantListsHelper
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