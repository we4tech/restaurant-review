module RestaurantsHelper

  def render_most_lovable_places(p_config, p_limit = 5)
    render :partial => 'restaurants/parts/lovable_places', :locals => {
        :more_link => most_loved_places_url,
        :config => p_config,
        :restaurants => Restaurant.most_loved(@topic, p_limit)}
  end

  def render_restaurant_review_stats(p_restaurant, p_short = true)
    reviews = p_restaurant.reviews
    variables = {
       :checkins_count => p_restaurant.checkins_count.to_i
    }

    if !reviews.empty?
      total_reviews_count = p_restaurant.reviews.count
      loved_count = p_restaurant.reviews.loved.count
      loved_percentage = (100 / total_reviews_count) * loved_count

      variables = variables.merge({
          :total_reviews_count => total_reviews_count,
          :loved_count => loved_count,
          :loved_percentage => loved_percentage
      })
    end

    render :partial => 'restaurants/parts/review_stats.html.erb', :locals => variables
  end

  def render_recently_added_places(p_config, p_limit = 10)
    render :partial => 'restaurants/parts/recently_reviewed_places', :locals => {
        :config => p_config,
        :more_link => recently_reviewed_places_url,
        :reviews => Review.recent.all(
            :include => [:restaurant], :limit => p_limit,
            :conditions => {:topic_id => @topic.id})}
  end

  def render_recently_added_pictures(p_limit = 5)
    render :partial => 'restaurants/parts/recently_added_pictures', :locals => {
        :title => 'Recently added pictures!',
        :more_link => recently_reviewed_places_url,
        :restaurants => Restaurant.recently_added_pictures(p_limit)}
  end

  def render_who_wanna_go_there(restaurant_or_event, limit = 5)
    wanna_go_reviews = restaurant_or_event.reviews.by_topic(@topic.id).wanna_go.all(:limit => limit, :include => [:user])
    link_options = {:id => restaurant_or_event.id, :name => url_escape(restaurant_or_event.name)}
    if restaurant_or_event.is_a?(TopicEvent)
      link_options[:mt] = :topic_event
    end

    render :partial => 'restaurants/parts/who_wanna_go_there', :locals => {
        :title => 'Who wanna visit here!',
        :reviews => wanna_go_reviews,
        :more_link => who_wanna_go_place_url(link_options)
    }
  end

  def render_tagcloud(p_config)
    bind_column = p_config['bind_column'].to_s
    field = @topic.form_attribute.fields.reject{|h| h if h['field'] != bind_column}
    tag_names = field.first ? (field.first['default_value'] || '').split('|') : []

    tags = Tag.all(:conditions => {:name => tag_names, :topic_id => @topic.id })
    
    render :partial => 'restaurants/parts/tagcloud', :locals => {
        :config => p_config,
        :tags => tags,
        :tag_groups => TagGroup.all,
        :column => bind_column.to_sym
    }
  end


  def render_feature_restaurants_box(options = {})
    @top_rated_restaurants = Restaurant.featured(@topic.id)
    render :partial => 'restaurants/parts/featured_restaurants_for_mail'  
  end
  
  def render_related_restaurants(per_page = 5)
    long_array = (@restaurant.long_array || []).collect{|l| l.downcase.sphinxify}
    short_array = (@restaurant.short_array || []).collect{|s| s.downcase.sphinxify}
    cuisine_tags = TagGroup::separate_tags(:cuisins, long_array).collect(&:sphinxify)
    long_array = long_array - cuisine_tags
    
    long_array_length = long_array.length - 1 > 0 ? long_array.length - 1 : 1
    short_array_length = 1
    
    
    # first search with strict location and cuisines
    queries = []
    # %{#{short_array.empty? ? '' : '@short_array '}#{short_array.join('|')} #{cuisine_tags.empty? ? '' : '@long_array '}#{cuisine_tags.join('|')} }.strip
    if !short_array.empty?
      queries << "@short_array #{short_array.join('|')}"
    end

    if !cuisine_tags.empty?
      queries << "@long_array #{cuisine_tags.join('|')}"
    end

    sphinxify_text = @restaurant.name.sphinxify
    if !sphinxify_text.strip.blank?
      queries << "@name -(#{sphinxify_text})"
    end

    restaurants = perform_search([:Restaurant], (queries.join(' ')), {:per_page => per_page, :page => 1})
    restaurants.uniq!
    
    # second find without location filter
    if restaurants.empty? || restaurants.length < per_page
      queries = []
      # %{@long_array #{cuisine_tags.join('|')} @name -(#{@restaurant.name})}
      if !cuisine_tags.empty?
        queries << "@long_array #{cuisine_tags.join('|')}"
        queries << "@name #{@restaurant.name.sphinxify})"
      end

      more_restaurants = perform_search([:Restaurant], (queries.join(' ')), {:per_page => per_page, :page => 1})
      more_restaurants.uniq!
      more_restaurants.each do |r|
        restaurants << r
      end
    end
    
    if restaurants.empty? || restaurants.length < per_page
      queries = []
      # %{@long_array "#{cuisine_tags.join(' ')} #{long_array.join(' ')}"/1 @name -(#{@restaurant.name})}
      if !cuisine_tags.empty?
        queries << "@long_array \"#{cuisine_tags.join('|')}"
      else
        queries << "@long_array \""
      end

      if !long_array.empty?
        queries << "#{long_array.join(' ')}\"/1"
      end
      
      queries << "@name -(#{@restaurant.name.sphinxify})"

      restaurant_ids = restaurants.collect(&:id)
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
	      render :partial => 'restaurants/parts/similar', :locals => {:restaurants => restaurants}
      else
        yield(restaurants)
      end
	  end
  end
end
