class HomeController < ApplicationController

  layout 'fresh'

  before_filter :log_new_feature_visiting_status
  before_filter :unset_premium_session 

  def index
    @title = I18n.t('header.recent_restaurants')
    @restaurants = Restaurant.by_topic(@topic.id).recent.paginate(:page => params[:page])
    
    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_search,
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_added_places]
    @breadcrumbs = []
  end

  def frontpage
    @title = I18n.t('header.recent_restaurants')
    page_index = params[:page].to_i > 0 ? params[:page].to_i : 1
    @restaurants = Restaurant.by_topic(@topic.id).recent.paginate(:page => page_index)
    @top_rated_restaurants = Restaurant.featured
    @location_tag_group = TagGroup.of('locations')

    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_search,
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_added_places]
    @breadcrumbs = []
  end

  def most_loved_places
    offset = params[:page].to_i
    offset = 1 if offset == 0

    @restaurants = WillPaginate::Collection.create(offset, Restaurant::per_page) do |pager|
      result = Restaurant.most_loved(@topic, Restaurant::NO_LIMIT, offset - 1)
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Restaurant.count_most_loved(@topic)
      end
    end

    load_module_preferences
    
    @title = I18n.t('header.loved_places')
    @site_title = @title

    @left_modules = [:render_search, :render_tagcloud, :render_recently_added_places]
    @breadcrumbs = [['All', root_url]]
    render :action => :index
  end

  def recently_reviewed_places
    offset = params[:page].to_i
    offset = 1 if offset == 0

    @restaurants = WillPaginate::Collection.create(offset, Restaurant::per_page) do |pager|
      result = Restaurant.recently_reviewed(@topic, Restaurant::NO_LIMIT, offset - 1)
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Restaurant.count_recently_reviewed(@topic)
      end
    end

    load_module_preferences
    
    @title = I18n.t('header.reviewed_places')
    @site_title = @title

    @display_last_review = true
    @left_modules = [:render_search, :render_tagcloud, :render_most_lovable_places]
    @breadcrumbs = [['All', root_url]]
    render :action => :index
  end

  def who_havent_been_there_before
    restaurant = Restaurant.find(params[:id].to_i)

    offset = params[:page].to_i
    offset = 1 if offset == 0

    @reviews = WillPaginate::Collection.create(offset, Restaurant::per_page) do |pager|
      result = restaurant.reviews.by_topic(@topic.id).wanna_go.all(
          :offset => (offset - 1), :limit => Restaurant::per_page, :include => [:user])
      pager.replace(result)

      unless pager.total_entries
        pager.total_entries = restaurant.reviews.by_topic(@topic.id).wanna_go.count
      end
    end

    load_module_preferences
    
    @title = I18n.t("header.wannago")
    @site_title = @title

    @left_modules = [:render_search, :render_tagcloud, :render_most_lovable_places, :render_recently_added_places]
    @breadcrumbs = [['All', root_url], [restaurant.name, restaurant_long_url(:id => restaurant.id, :name => url_escape(restaurant.name))]]
    @restaurant = restaurant
  end

  def tag_details
    label = params[:label]
    label = label.gsub('-', ' ').downcase
    tag_string = (URI.unescape(params[:tag]) || '').gsub('-', ' ').downcase
    tag = Tag.find_by_name_and_topic_id(tag_string, @topic.id)

    # Find out associated label
    selected_module = nil
    @topic.modules.each do |m|
      if m['label'].downcase.parameterize.gsub('-', ' ') == label
        selected_module = m
      end
    end

    if !selected_module
      render :status => 404, :text => 'This url doesn\'t exists'
      return
    end

    if tag
      @restaurants = tag.restaurants.paginate :page => params[:page]
      load_module_preferences

      @title = I18n.t('header.tag_details', :tag => tag.name)
      @site_title = @title
      @left_modules = [:render_search,
                       :render_tagcloud, :render_recently_added_places]
      @breadcrumbs = [['All', root_url]]
      render :action => :index
    else
      flash[:notice] = I18n.t('errors.invalid_tag', :tag => label)
      redirect_to root_url
    end
  end

  def search
    @title = I18n.t('header.search_results')
    @site_title = @title
    @restaurants = WillPaginate::Collection.create(1, Restaurant::per_page) do |pager|
      pager.replace([])
      pager.total_entries = 0
    end

    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_search,
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_added_places]
    @breadcrumbs = []
  end

  def photos
    @stuff_events = StuffEvent.paginate(
        :conditions => {
            :topic_id => @topic.id,
            :event_type => [StuffEvent::TYPE_RELATED_IMAGE,
                            StuffEvent::TYPE_CONTRIBUTED_IMAGE],
            },
        :order => 'created_at DESC',
        :include => [:image, :restaurant],
        :page => params[:page])

    load_module_preferences

    @title = I18n.t('header.photos')
    @site_title = @title
    @left_modules = [:render_search,
                     :render_tagcloud, :render_most_lovable_places,
                     :render_recently_added_places]
    @breadcrumbs = [['All', root_url]]
  end

  def show_photo
    @stuff_event = StuffEvent.find(params[:id].to_i)
    @related_image = @stuff_event.image

    load_module_preferences

    @title = @related_image.caption
    @title = nil if @title.nil? || @title.blank?

    @site_title = @title
    @left_modules = [:render_search, :render_tagcloud, :render_most_lovable_places, :render_recently_added_places]
    @breadcrumbs = [['All', root_url],
                    ['Photos', photos_url(:page => params[:page])]]
  end

  def static_page
      
  end

  def recommend
    @tag_ids = params[:tag_ids] || []
    if @tag_ids.is_a?(Hash)
      @tag_ids = @tag_ids.values
    end

    if @tag_ids.empty?
      @restaurants = []
    else
      @tag_ids = @tag_ids.collect(&:to_i)
      @restaurants = load_paginated_restaurants
    end

    @breadcrumbs = [['Home', root_url]]
    @title = I18n.t('header.recommend')
    @site_title = @title

    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_search,
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_added_places]
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
