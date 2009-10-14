class HomeController < ApplicationController
  layout 'fresh'

  def index
    @restaurants = Restaurant.recent 
  end
end
