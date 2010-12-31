class MapController < ApplicationController

  layout 'fresh'

  def full_view
    @restaurant = Restaurant.find(params[:rid])
    @site_title = @restaurant.name
  end
end
