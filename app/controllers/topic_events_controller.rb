class TopicEventsController < ApplicationController

  before_filter :login_required, :except => [:index, :show]
  caches_action :show, :cache_path => Proc.new { |c|
    c.cache_path(c, [:id])
  }, :if => Proc.new { |c| !c.send(:mobile?) }

  # TODO: It doesn't support pagination
  def index
    @topic_events = TopicEvent.exciting_events(@topic, :limit => 50)
    @breadcrumbs = [[t('layout.links.home'), root_url], ['Events']]
    @title = @site_title = t('header.all_events')
    page_context :list_page

    @cached = true
    @right_button = ['Add your EVENT', new_event_path]
    @right_button_icon = 'icon_add'

    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
      :render_tagcloud,
      :render_most_lovable_places,
      :render_recently_reviewed_places]
    @breadcrumbs = [['All', root_path]]
  end

  def new
    page_context [:list_page, :form_page]
    @event = TopicEvent.new
    @parent_events = TopicEvent.open_events
    @breadcrumbs = [[t('layout.links.home'), root_url], ['Events', events_path]]
    @site_title = @title = 'New Event'
    render_view 'topic_events/new'
  end

  def create
    page_context [:list_page, :form_page]
    @event = TopicEvent.new(params[:event])
    @event.topic_id = @topic.id
    @event.user_id = current_user.id

    if @event.save
      notify :success, events_path
    else
      flash[:notice] = 'Failed to create new event'
      @parent_events = TopicEvent.open_events
      @breadcrumbs = [[t('layout.links.home'), root_url], ['Events', events_path]]
      @site_title = @title = 'New Event'
      render_view 'topic_events/new'
    end
  end

  def edit
    page_context [:list_page, :form_page]
    @event = TopicEvent.find(params[:id])
    @parent_events = TopicEvent.open_events
    @breadcrumbs = [['Events', events_path],
                    [@event.name, event_long_url(@event)]]
    @site_title = @title = 'Edit'
    render_view 'topic_events/new'
  end

  def update
    @event = TopicEvent.find(params[:id])
    event_attributes = params[:event]
    event_attributes.delete(:user_id)
    event_attributes.delete(:topic_id)

    if @event.update_attributes(event_attributes)
      notify :success, edit_event_path(@event)
    else
      flash[:notice] = 'Failed to update topic event'
      @parent_events = TopicEvent.open_events
      @breadcrumbs = [[t('layout.links.home'), root_url],
                      ['Events', events_path],
                      [@event.name, event_long_url(@event)],
                      ['Edit Event']]
      render_inside 'topic_events/new'
    end
  end

  def show
    @event = TopicEvent.find(params[:id])
    @site_title = "#{@event.name} #{@event.address.blank? ? '' : "@ #{@event.address}"} "
    page_context :details_page
    @cached = true

    if @event.reviews.count > 0
      user_given_rating = @event.rating_out_of(Restaurant::RATING_LIMIT)
      @meta_description = "Read unbiased reviews of " +
        "#{@event.reviews.count} people, who loved and rated " +
        "'#{@event.name}' in average " +
        "#{user_given_rating > 0 ? user_given_rating.round(1) : 0}" +
        " out of #{Restaurant::RATING_LIMIT.to_f} "
    else
      @meta_description = "Read unbiased reviews of '#{@event.name}'"
    end

    load_module_preferences
    @view_context = ViewContext::CONTEXT_EVENT_DETAILS
    @left_modules = [
      :render_tagcloud,
      :render_search,
      :render_most_lovable_places,
      :render_recently_reviewed_places,
      :render_topic_box]
  end

  def destroy
    event = TopicEvent.find(params[:id])
    if event.author?(current_user)
      if event.destroy
        notify :success, events_path
      else
        notify :failure, events_path
      end
    end
  end

  private
  def render_inside(template)
    @inner_page = template
    render :partial => 'layouts/topic_event_layout', :layout => 'fresh'
  end
end
