class StuffEventsController < ApplicationController

  before_filter :login_required

  def show
    @site_title = 'Activities from others'
    @subscribed_restaurants = current_user.subscribed_restaurants.find(:all, :group => 'restaurants.id')
    @stuff_events = StuffEvent.paginate(
        :include => [:restaurant, :review, :review_comment],
        :conditions => [
            'restaurant_id IN (?) AND user_id != ?',
            @subscribed_restaurants.collect{|r| r.id},
            current_user.id],
        :order => 'created_at DESC',
        :page => params[:page])

    @left_modules = [:render_most_lovable_places, :render_recently_added_places]
    @breadcrumbs = [['All', root_url]]
  end
end
