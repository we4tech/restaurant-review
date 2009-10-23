class RestaurantsController < ApplicationController

  def new
    @restaurant = Restaurant.new
  end

  def create
    @restaurant = Restaurant.new(params[:restaurant])
    @restaurant.user = current_user
    if @restaurant.save
      flash[:notice] = 'Successfully saved new restaurant!'
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url('new_restaurant', @restaurant.id, :next_to => edit_restaurant_url(@restaurant))
      else
        redirect_to edit_restaurant_url(@restaurant)
      end
    else
      flash[:notice] = 'Failed to store new restaurant!'
    end
  end

  def show
    @restaurant = Restaurant.find(params[:id].to_i)
  end

  def edit
    restaurant = Restaurant.find(params[:id].to_i)
    if restaurant.author?(current_user)
      @restaurant = restaurant
    else
      flash[:notice] = "You are not authorized to edit this entry!"
      redirect_to root_url
    end
  end

  def update
    restaurant = Restaurant.find(params[:id].to_i)
    if restaurant.update_attributes(params[:restaurant])
      restaurant.update_attribute(:user_id, current_user.id)
      if current_user.share_on_facebook?
        flash[:notice] = 'Saved and shared your updates!'
        redirect_to facebook_publish_url('updated_restaurant', restaurant.id, :next_to => edit_restaurant_url(restaurant))
      else
        flash[:notice] = 'Saved your updates!'
        redirect_to edit_restaurant_url(restaurant)
      end
    else
      flash[:notice] = 'Failed to store your updated!'
      redirect_to edit_restaurant_url(restaurant)
    end
  end

  def destroy
    restaurant = Restaurant.find(params[:id].to_i)
    if restaurant.author?(current_user)
      if restaurant.destroy
        flash[:notice] = "You have removed an entry - #{restaurant.name}"
      else
        flash[:notice] = "Failed to remove this entry - #{restaurant.name}"
      end
    else
      flash[:notice] = "You are not authorized to delete this entry!"
    end

    redirect_to root_url
  end

end
