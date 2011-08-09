class StuffEventsController < ApplicationController

  before_filter :login_required, :except => [:show]
  before_filter :log_new_feature_visiting_status
  after_filter  :log_last_visiting_time

  def show
    data = recent_activities
    page_context :list_page
    @cache = true
    @title = 'Updates'


    @stuff_events = data[:stuff_events]
    @user_log = data[:user_log]
    @full_view = true

    respond_to do |format|
      format.html {
        load_module_preferences
        @left_modules = [
            :render_topic_box,
            :render_tagcloud,
            :render_most_lovable_places,
            :render_recently_reviewed_places]
        prepare_breadcrumbs
        @site_title = @tag ? "#{@tag.name_with_group} updates" : 'Updates'
      }

      format.ajax { render :layout => false}
      format.mobile {
        prepare_breadcrumbs
        @site_title = @tag ? "#{@tag.name_with_group} updates" : 'Updates'
      }
    end

  end
end
