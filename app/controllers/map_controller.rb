class MapController < ApplicationController

  layout 'fresh'

  def full_view
    if params[:rid]
      @model_instance = Restaurant.find(params[:rid])
    elsif params[:eid]
      @model_instance = TopicEvent.find(params[:eid])
    else
      flash[:notice] = 'Invalid parameter'
      redirect_to :back
      return
    end

    @site_title = @model_instance.name
  end
end
