class FeedsController < ApplicationController

  def reviews
    @reviews = Review.recent.find(:all, :limit => 20, :include => [:restaurant, :user])
    respond_to do |format|
      format.html
      format.json { render :json => @reviews }
      format.xml { render :xml => @reviews }
      format.atom
    end
  end

end
