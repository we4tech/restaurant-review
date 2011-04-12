class StuffEventsController < ApplicationController

  before_filter :login_required, :except => [:show]
  before_filter :log_new_feature_visiting_status
  after_filter  :log_last_visiting_time

  def show
    @site_title = 'Activities from others'
    @subscribed_restaurants = []
    @user_log = nil

    if current_user
      @subscribed_restaurants = current_user.subscribed_restaurants.by_topic(@topic.id).
          find(:all, :group => 'restaurants.id')
      @user_log = current_user.user_logs.by_topic(@topic.id).first
      conditions = [
          'topic_id = ?   AND restaurant_id IN (?) AND user_id != ?',
          @topic.id, @subscribed_restaurants.collect(&:id), current_user.id]
    else
      conditions = ['topic_id = ?', @topic.id]
    end

    @stuff_events = StuffEvent.paginate(
        :include => [:restaurant, :review, :review_comment],
        :conditions => conditions,
        :order => 'created_at DESC',
        :page => params[:page])

    respond_to do |format|
      format.html {
        load_module_preferences
        @left_modules = [
            :render_topic_box,
            :render_tagcloud,
            :render_most_lovable_places,
            :render_recently_added_places]
        @breadcrumbs = [['All', root_url]]
      }

      format.ajax { render :layout => false}
      format.mobile {
        @breadcrumbs = [['All', root_url]] 
      }
    end

  end
end
