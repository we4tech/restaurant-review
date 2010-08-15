class FoodItemsController < ApplicationController

  before_filter :load_restaurant, :except => [:index]

  def index
    @site_title = 'Food Menu'
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    render_view 'food_items/index'
  end

  def new
    @food_item = FoodItem.new
    @food_item.restaurant_id = @restaurant.id

    if params[:parent]
      @food_item.food_item_id = params[:parent].to_i  
    end

    render_view 'food_items/new'
  end

  def create
    if_permits?(@restaurant) do
      @food_item = FoodItem.new(params[:food_item])
      @food_item.user = current_user
      if @food_item.save
        notify :success, new_restaurant_food_item_path(@restaurant, :parent => @food_item.food_item_id)
      else
        flash[:notice] = 'Error found'
        render_view 'food_items/new'
      end
    end
  end

  def destroy
    if_permits?(@restaurant) do
      if FoodItem.find(params[:id].to_i).destroy
        notify :success, restaurant_food_items_path(@restaurant)
      else
        notify :failure, restaurant_food_items_path(@restaurant)
      end
    end
  end

  def edit
    if_permits?(@restaurant) do
      @food_item = FoodItem.find(params[:id].to_i)
      render_view 'food_items/edit'
    end
  end

  def update
    if_permits?(@restaurant) do
      @food_item = FoodItem.find(params[:id].to_i)
      attributes = params[:food_item]
      attributes.delete(:user_id)
      attributes.delete(:restaurant_id)

      if @food_item.update_attributes(attributes)
        notify :success, restaurant_food_items_path(@restaurant)
      else
        flash[:notice] = 'Failed to update'
        render_view 'food_items/edit'
      end
    end
  end

  def add_image
    if_permits?(@restaurant) do
      @food_item = FoodItem.find(params[:id].to_i)
      render_view 'food_items/add_image'
    end
  end

  private
    def load_restaurant
      if params[:restaurant_id]
        @restaurant = Restaurant.find(params[:restaurant_id].to_i)
      elsif params[:food_item][:restaurant_id]
        @restaurant = Restaurant.find(params[:food_item][:restaurant_id].to_i)
      end
    end
end
