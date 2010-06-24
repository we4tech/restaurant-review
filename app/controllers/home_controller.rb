class HomeController < ApplicationController

  layout 'fresh'

  before_filter :log_new_feature_visiting_status
  #caches_action :index, :if => Proc.new {|c|
  #  c.send(:current_user).nil? && c.send(:flash)[:notice].nil?
  #} 

  def index
    @title = 'Recently added restaurants!'
    @restaurants = Restaurant.by_topic(@topic.id).recent.paginate(:page => params[:page])
    
    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_topic_box,
        :render_search, 
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_added_places]
    @breadcrumbs = []
  end

  def frontpage
    @title = 'Recently added restaurants!'
    @restaurants = Restaurant.by_topic(@topic.id).recent.paginate(:page => params[:page])
    @top_rated_restaurants = Restaurant.most_loved(@topic, 5)

    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_topic_box,
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
    
    @title = 'Most loved places!'
    @left_modules = [:render_topic_box, :render_search, :render_tagcloud, :render_recently_added_places]
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
    
    @title = 'Recently reviewed places!'
    @display_last_review = true
    @left_modules = [:render_topic_box, :render_search, :render_tagcloud, :render_most_lovable_places]
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
    
    @title = "Who else wanna visit this place!"
    @left_modules = [:render_topic_box, :render_search, :render_tagcloud, :render_most_lovable_places, :render_recently_added_places]
    @breadcrumbs = [['All', root_url], [restaurant.name, restaurant_url(restaurant)]]
    @restaurant = restaurant
  end

  def tag_details
    label = params[:label]
    label = label.gsub('-', ' ').downcase
    tag_string = URI.unescape(params[:tag])
    tag = Tag.find_by_name_and_topic_id(tag_string, @topic.id)

    # Find out associated label
    selected_module = nil
    @topic.modules.each do |m|
      if m['label'].downcase.parameterize.gsub('-', ' ') == label
        selected_module = m
      end
    end

    if tag
      @restaurants = tag.restaurants.paginate :page => params[:page]
      load_module_preferences

      @title = "#{selected_module['label']} » #{tag.name}"
      @left_modules = [:render_topic_box, :render_search, :render_tagcloud, :render_recently_added_places]
      @breadcrumbs = [['All', root_url]]
      render :action => :index
    else
      flash[:notice] = "Invalid tag label - #{label}"
      redirect_to :back
    end
  end

  def search
    @title = 'Search results!'
    @restaurants = WillPaginate::Collection.create(1, Restaurant::per_page) do |pager|
      pager.replace([])
      pager.total_entries = 0
    end

    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_topic_box,
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
                            StuffEvent::TYPE_CONTRIBUTED_IMAGE]},
        :order => 'created_at DESC',
        :include => [:image, :restaurant],
        :page => params[:page])

    load_module_preferences

    @title = "Pictures from restaurants!"
    @left_modules = [:render_topic_box, :render_search, :render_tagcloud, :render_most_lovable_places, :render_recently_added_places]
    @breadcrumbs = [['All', root_url]]
  end

  def show_photo
    @stuff_event = StuffEvent.find(params[:id].to_i)
    @related_image = @stuff_event.image

    load_module_preferences

    @title = @related_image.caption
    @title = nil if @title.nil? || @title.blank?

    @site_title = @title
    @left_modules = [:render_topic_box, :render_search, :render_tagcloud, :render_most_lovable_places, :render_recently_added_places]
    @breadcrumbs = [['All', root_url],
                    ['Photos', photos_url(:page => params[:page])]]
  end

  def static_page
      
  end
end
