class HomeController < ApplicationController

  layout 'fresh'

  before_filter :log_new_feature_visiting_status
  before_filter :unset_premium_session 
  
  caches_action :frontpage, :index, :most_loved_places, 
                :most_checkedin_places, :recently_reviewed_places, 
                :recent_places, :photos, :cache_path => Proc.new {|c| 
    c.cache_path(c)
  }, :if => Proc.new {|c| !c.send(:mobile?)}

  def index
    @title = I18n.t('header.recent_restaurants')
    @restaurants = Restaurant.by_topic(@topic.id).recent.paginate(:page => params[:page])
    @cached = true
    page_context :list_page
    
    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_reviewed_places]
    @breadcrumbs = []
  end

  def frontpage
    @title = I18n.t('header.recent_restaurants')    
    @location_tag_group = TagGroup.of(@topic, 'locations')
    @best_for_tags = Tag.featurable(@topic.id)
    @cached = true if params[:jsonp].nil? || params[:jsonp] != 'false'
    page_context :frontpage

    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_reviewed_places]
    @breadcrumbs = []
    
    respond_to do |format|
      format.html { render_topic_template('frontpage', :default => 'home/frontpage.html.erb') }
	    format.mobile { render }
      format.mobile_touch { render }
      format.xml {
      	options = {}
      	options[:only] = params[:fields].collect(&:to_sym) if params[:fields]
      	render :xml => @restaurants.to_xml(options)
      }
    end
  end
  
  def recent_places
    offset = params[:page].to_i
    offset = 1 if offset == 0
    filters = params[:filters]
    page_context :list_page
    @cached = true
    
    if filters && filters[:user_id].present?
      @restaurants = Restaurant.by_users(filters[:user_id].split('|')).by_topic(@topic.id).recent.paginate :page => params[:page]
    else
      @restaurants = Restaurant.by_topic(@topic.id).recent.paginate :page => params[:page]      
    end

    @title = 'Recently explored places'
    @site_title = @title

    prepare_breadcrumbs
    render :action => :index
  end

  def most_loved_places
    offset = params[:page].to_i
    offset = 1 if offset == 0
    filters = params[:filters]
    page_context :list_page
    @cached = true

    @restaurants = WillPaginate::Collection.create(offset, Restaurant::per_page) do |pager|
      if filters && filters[:user_id].present?
        result = Restaurant.most_loved_by_users(@topic, User.find(filters[:user_id].split('|')), Restaurant::per_page, offset - 1)
      else
        result = Restaurant.most_loved(@topic, Restaurant::NO_LIMIT, offset - 1)
      end
      
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Restaurant.count_most_loved(@topic)
      end
    end

    @title = I18n.t('header.loved_places')
    @site_title = @title
    prepare_breadcrumbs
    render :action => :index
  end
  
  def most_checkedin_places
  	offset = params[:page].to_i
    offset = 1 if offset == 0
    filters = params[:filters] || {}
    page_context :list_page
    @cached = true
    
    if filters[:user_id].present?
      users = User.find(filters[:user_id].split('|'))
    else
      users = []
    end

    @restaurants = WillPaginate::Collection.create(offset, Restaurant::per_page) do |pager|
      if filters[:user_id].present?
        result = Restaurant.most_checkined_by_users(@topic, users, Restaurant::per_page, offset - 1)
      else
        result = Restaurant.most_checkined(@topic, Restaurant::NO_LIMIT, offset - 1)
      end      
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        if filters[:user_id].present?
          pager.total_entries = Restaurant.count_checkined_by_users(@topic, users)
        else
          pager.total_entries = Restaurant.count_most_checkined(@topic)
        end
      end
    end

    @title = "Most checked in places"
    @site_title = @title
    prepare_breadcrumbs
    
    render :action => :index
  end

  def recently_reviewed_places
    offset = params[:page].to_i
    filters = params[:filters]
    offset = 1 if offset == 0
    @cached = true
    page_context :list_page
    
    if filters && filters[:user_id].present?
      @show_reviews_from = User.find(filters[:user_id].split('|'))
    end
    
    @restaurants = WillPaginate::Collection.create(offset, Restaurant::per_page) do |pager|
      if @show_reviews_from.present?
        result = Review.by_topic(@topic.id).by_users(@show_reviews_from.collect(&:id)).recent.all(:limit => Restaurant::per_page, :offset => offset - 1).collect { |r| r.restaurant || r.topic_event }
      else
        result = Restaurant.recently_reviewed(@topic, Restaurant::NO_LIMIT, offset - 1)
      end
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        if @show_reviews_from.present?
          pager.total_entries = Review.by_users(@show_reviews_from.collect(&:id)).recent.count
        else
          pager.total_entries = Restaurant.count_recently_reviewed(@topic)
        end
      end
    end
    
    @title = I18n.t('header.reviewed_places')
    @site_title = @title
    @display_last_review = true
    prepare_breadcrumbs
    
    render :action => :index
  end

  def who_havent_been_there_before
    model_type = (params[:mt] || 'restaurant').camelize.constantize
    model_instance = model_type.find(params[:id].to_i)
    page_context :list_page

    offset = params[:page].to_i
    offset = 1 if offset == 0

    @reviews = WillPaginate::Collection.create(offset, model_type::per_page) do |pager|
      result = model_instance.reviews.by_topic(@topic.id).wanna_go.all(
          :offset => (offset - 1), :limit => model_type::per_page, :include => [:user])
      pager.replace(result)

      unless pager.total_entries
        pager.total_entries = model_instance.reviews.by_topic(@topic.id).wanna_go.count
      end
    end

    load_module_preferences
    
    @title = I18n.t("header.wannago", :place => model_instance.name)
    @site_title = @title

    @left_modules = [:render_tagcloud, :render_most_lovable_places, :render_recently_reviewed_places]
    @breadcrumbs = [['All', root_or_specific_root_url(model_instance)], [model_instance.name, event_or_restaurant_url(model_instance)]]
    @restaurant = model_instance
  end

  def tag_details
    label = params[:label]
    label = label.gsub('-', ' ').downcase
    tag_string = (URI.unescape(params[:tag]) || '').gsub('-', ' ').downcase
    tag = Tag.find_by_name_and_topic_id(tag_string, @topic.id)
    session[:last_tag_id] = tag.id
    page_context :list_page
   	page_module :body, :render_news_feed, {:label => 'News Feed', :limit => 5, :filters => { :tag_id => tag.id }}

    if tag
      @restaurants = tag.restaurants.paginate :include => {:tags => [:tag_groups], :related_images => [:image]}, :page => params[:page]
      load_module_preferences

      @title = tag.name_with_group
      @site_title = @title
      @left_modules = [:render_tagcloud, :render_recently_reviewed_places]
      @breadcrumbs = [['All', root_url]]
      render :action => :index
    else
      flash[:notice] = I18n.t('errors.invalid_tag', :tag => label)
      redirect_to root_url
    end
  end

  BANNED_PARAM_KEYS = ['_models', 'action', 'controller', 'l', 'page', 'format']
  ALLOWED_PARAM_KEY_NEEDLE = ['short_array', 'long_array', 'description', 'name', 'address']
   	
  def search
    @title = I18n.t('header.search_results')
    @site_title = @title
    page_context :list_page

    models = []
    if params[:_models] 
      models = params[:_models].split(',').collect{|m| m.strip.blank? ? nil : m.strip}.compact
   	end
   	
   	query_map = {}
   	@tags = []
   	params.each do |k, v|
   	  v = v.collect{|mv| mv if !mv.blank?}.compact if v.is_a?(Array)
   	  k = k.gsub(/[%25C7]+/, '|')
   	  if !v.blank? && allowed_key?(k)
   		  query_map[k] = v 
   		
   		  if v.is_a?(Array)
   		    v.each{|vi| @tags << vi.downcase if !vi.blank?}
   		  elsif v.is_a?(Hash)
   		    v.values.each{|vi| @tags << vi.downcase if vi}
   		  else
   		    @tags << v.downcase
   		  end
   	  end
   	end
   	
   	# Determine location parameters
   	options = {}
   	
   	options[:per_page] = params[:limit].to_i if params[:limit]
   	
   	if params[:lat].to_f > 0 && params[:lng].to_f > 0 && params[:meter].to_i > 0
   	  options[:location] = {
   	    :lat => params[:lat],
   	    :long => params[:lng],
   	    :meter => params[:meter]
   	  }
   	  
   	  @location = options[:location]
 	  end
   		
	  @tag_ids = []
    @restaurants = perform_search(models, build_search_query(query_map, @tags), options)
    
    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_reviewed_places]
    @breadcrumbs = []
    @searched_tags = @tags
    respond_to do |format|
      format.html { render :action => :recommend }
      format.mobile { render :action => :recommend }
      format.ajax { render :action => :recommend, :layout => false }
      format.json do 
      	options = {}
      	options[:only] = params[:fields].collect(&:to_sym) if params[:fields]
      	excepts = params[:excepts] ? params[:excepts] : []
      	image_versions = params[:image_versions] ? params[:image_versions] : []
      	
      	@display_last_review = true
      	json_attributes = @restaurants.collect do |r| 
      	  attributes = {
      		  :id => r.id, :address => r.address, 
      		  :lat => r.lat, :lng => r.lng, 
      		  :name => r.name, :reviews_count => r.reviews.count,
      		  :reviews_loved => r.reviews.loved.count, :reviews_hated => r.reviews.hated.count,
      		  :marker_icon => 'http://maps.google.com/mapfiles/kml/pal2/icon40.png',
      		  :marker_icon_shadow => 'http://maps.google.com/mapfiles/kml/pal2/icon40s.png',
      		  :url => restaurant_long_url(r)
    		  }
      		  
      		['marker_html', 'description'].each do |field|
      		  if !excepts.include?(field)
      		    attributes[field.to_sym] = render_to_string(
      		      :partial => 'restaurants/parts/restaurant.html.erb', 
      		      :locals => {:restaurant => r, :only_html => true})
      		  end
    		  end
    		  
    		  # Add images
    		  if !image_versions.empty? && !r.all_images.empty?
    		    image_versions.each do |version|
    		      version.strip!
    		      attributes["image_#{version}".to_sym] = r.all_images.collect{|img| "http://#{request.host}#{img.public_filename(version.to_sym)}" }
  		      end
  		    end
  		    
  		    attributes
  		  end
  		  
  		  render :json => json_attributes
      end
      
      format.xml { 
      	options = {}
      	options[:only] = params[:fields].collect(&:to_sym) if params[:fields]
      	render :xml => @restaurants.to_xml(options) 
      }
    end
  end
  
  def allowed_key?(key)
  	ALLOWED_PARAM_KEY_NEEDLE.each do |needle|
  	  return true if key.include?(needle)
  	end
  	false
  end

  def photos
  	page_context :list_page
  	@cached = true
  	
    @stuff_events = StuffEvent.paginate(
        :conditions => {
            :topic_id => @topic.id,
            :event_type => [StuffEvent::TYPE_RELATED_IMAGE,
                            StuffEvent::TYPE_CONTRIBUTED_IMAGE],
            },
        :order => 'created_at DESC',
        :include => {:image => [:photo_comments], :restaurant => []},
        :page => params[:page])

    load_module_preferences

    @title = 'Restaurants picture'
    @site_title = @title
    @left_modules = [:render_tagcloud, :render_most_lovable_places,
                     :render_recently_reviewed_places]
    @breadcrumbs = [['All', root_url]]
  end

  def show_photo
  	page_context :list_page
    @stuff_event = StuffEvent.find(params[:id].to_i)
    @related_image = @stuff_event.image

    load_module_preferences

    @title = @related_image.caption
    @title = nil if @title.nil? || @title.blank?

    @site_title = @title
    @left_modules = [:render_tagcloud, :render_most_lovable_places, :render_recently_reviewed_places]
    @breadcrumbs = [['All', root_url],
                    ['Photos', photos_url(:page => params[:page])]]
  end

  def static_page
      
  end

  def recommend
  	page_context :list_page
    tag_ids = params[:tag_ids] || []
    tag_ids = tag_ids.values if tag_ids.is_a?(Hash)
    tags = tag_ids.collect{|tag_id| Tag.find(tag_id)}
    url_params = {'_models' => 'Restaurant'}
    tags.each do |tag|
      url_params['short_array|long_array[]'] = tag.name
    end
    
    redirect_to search_url(url_params)
  end
  
  def to_liquid
    self
  end

  private
    def load_paginated_restaurants
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      joins = ''
      conditions = ''
      @tag_ids.each_with_index do |tag_id, index|
        joins << " LEFT JOIN tag_mappings tm#{index}
                   ON tm#{index}.restaurant_id = restaurants.id
                   AND tm#{index}.topic_id=#{@topic.id}"

        conditions << "tm#{index}.tag_id=#{tag_id}"
        if index < @tag_ids.length - 1
          conditions << ' AND '
        end
      end

      WillPaginate::Collection.create(page, Restaurant.per_page) do |pager|
        pager.replace(Restaurant.all(
            :conditions => conditions, :joins => joins,
            :offset => pager.offset, :limit => pager.per_page))

        unless pager.total_entries
          pager.total_entries = Restaurant.count(
              :conditions => conditions, :joins => joins)
        end
      end
    end
end
