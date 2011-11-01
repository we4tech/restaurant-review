class MapController < ApplicationController

  layout 'fresh'

  def full_view
    page_context :list_page

    @breadcrumbs = []

    if params[:rid]
      @model_instance = Restaurant.find(params[:rid])
      @restaurant = @model_instance
    elsif params[:eid]
      @model_instance = TopicEvent.find(params[:eid])
    else
      flash[:notice] = 'Invalid parameter'

      if redirectable?
        redirect_to :back
      else
        redirect_to root_path
      end

      return
    end

    @breadcrumbs << [@model_instance.name, event_or_restaurant_url(@model_instance)]
    @site_title = "Details map of #{@model_instance.name}"
    @title = "Details map"
  end
end
