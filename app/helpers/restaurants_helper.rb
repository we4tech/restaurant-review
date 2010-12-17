module RestaurantsHelper

  def render_most_lovable_places(p_config, p_limit = 5)
    render :partial => 'restaurants/parts/lovable_places', :locals => {
        :more_link => most_loved_places_url,
        :config => p_config,
        :restaurants => Restaurant.most_loved(@topic, p_limit)}
  end

  def render_restaurant_review_stats(p_restaurant, p_short = true)
    reviews = p_restaurant.reviews
    if !reviews.empty?
      total_reviews_count = p_restaurant.reviews.count
      loved_count = p_restaurant.reviews.loved.count
      loved_percentage = (100 / total_reviews_count) * loved_count

      variables = {
          :total_reviews_count => total_reviews_count,
          :loved_count => loved_count,
          :loved_percentage => loved_percentage
      }

      if params[:format].to_s == 'atom'
        render :partial => 'restaurants/parts/review_stats.html.erb', :locals => variables
      else
        render :partial => 'restaurants/parts/review_stats', :locals => variables
      end
    end
  end

  def render_recently_added_places(p_config, p_limit = 10)
    render :partial => 'restaurants/parts/recently_reviewed_places', :locals => {
        :config => p_config,
        :more_link => recently_reviewed_places_url,
        :reviews => Review.by_topic(@topic.id).recent.all(:include => [:restaurant], :limit => p_limit)}
  end

  def render_recently_added_pictures(p_limit = 5)
    render :partial => 'restaurants/parts/recently_added_pictures', :locals => {
        :title => 'Recently added pictures!',
        :more_link => recently_reviewed_places_url,
        :restaurants => Restaurant.recently_added_pictures(p_limit)}
  end

  def render_who_wanna_go_there(p_restaurant, p_limit = 5)
    wanna_go_reviews = p_restaurant.reviews.by_topic(@topic.id).wanna_go.all(:limit => p_limit, :include => [:user])
    render :partial => 'restaurants/parts/who_wanna_go_there', :locals => {
        :title => 'Who wanna visit here!',
        :reviews => wanna_go_reviews,
        :more_link => who_wanna_go_place_url(:id => p_restaurant.id, :name => p_restaurant.name.parameterize.to_s)
    }
  end

  def render_tagcloud(p_config)
    bind_column = p_config['bind_column'].to_s
    field = @topic.form_attribute.fields.reject{|h| h if h['field'] != bind_column}
    tag_names = field.first ? (field.first['default_value'] || '').split('|') : []

    tags = Tag.all(:conditions => {
        :name => tag_names,
        :topic_id => @topic.id })
    
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
    long_array = (@restaurant.long_array || []).collect(&:downcase)
    short_array = (@restaurant.short_array || []).collect(&:downcase)
    cuisin_tags = TagGroup::separate_tags(:cuisins, long_array)
    long_array = long_array - cuisin_tags
    
    long_array_length = long_array.length - 1 > 0 ? long_array.length - 1 : 1
    short_array_length = 1
    
    
    # first search with strict location and cusinis 
    restaurants = perform_search([:Restaurant], (%{@short_array #{short_array.join('|')} @long_array #{cuisin_tags.join('|')} @name -(#{@restaurant.name})}), {:per_page => per_page, :page => 1})
    
    # second find without location filter
    if restaurants.empty? || restaurants.length < per_page
      more_restaurants = perform_search([:Restaurant], (%{@long_array #{cuisin_tags.join('|')} @name -(#{@restaurant.name})}), {:per_page => per_page, :page => 1})
      more_restaurants.each do |r|
        restaurants << r
      end
    end
    
    if restaurants.empty? || restaurants.length < per_page
      restaurant_ids = restaurants.collect(&:id)
      more_restaurants = perform_search([:Restaurant], (%{@long_array "#{cuisin_tags.join(' ')} #{long_array.join(' ')}"/1 @name -(#{@restaurant.name})}), {:per_page => 10, :page => 1})
      more_restaurants.each do |r|
      	if !restaurant_ids.include?(r.id)
      	  restaurants << r
      	end
      end      
    end  
    
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
