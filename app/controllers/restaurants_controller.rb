class RestaurantsController < ApplicationController

  before_filter :login_required, :except => [:show]
  before_filter :log_new_feature_visiting_status

  def new
    @restaurant = Restaurant.new
    @form_fields = @topic.form_attribute.fields
    @allow_image_upload = @topic.form_attribute.allow_image_upload
    @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
  end

  def create
    @allow_image_upload = @topic.form_attribute.allow_image_upload
    @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
    @restaurant = Restaurant.new(params[:restaurant])
    @restaurant.user = current_user
    @restaurant.topic_id = @topic.id

    if @restaurant.save
      flash[:notice] = 'Successfully saved new restaurant!'
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url('new_restaurant', @restaurant.id, :next_to => edit_restaurant_url(@restaurant))
      else
        redirect_to edit_restaurant_url(@restaurant)
      end
    else
      @form_fields = @topic.form_attribute.fields
      flash[:notice] = "Failed to store new #{@topic.name.humanize} information!"
      render :action => :new
    end
  end

  def show
    @restaurant = Restaurant.find(params[:id].to_i)
    @site_title = @restaurant.name
    @form_fields = @topic.form_attribute.fields
    @allow_image_upload = @topic.form_attribute.allow_image_upload
    @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
  end

  def edit
    @form_fields = @topic.form_attribute.fields
    @allow_image_upload = @topic.form_attribute.allow_image_upload
    @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
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
      restaurant.update_attributes(
          :user_id => current_user.id,
          :topic_id => @topic.id)
      if current_user.share_on_facebook?
        flash[:notice] = 'Saved and shared your updates!'
        redirect_to facebook_publish_url('updated_restaurant', restaurant.id, :next_to => edit_restaurant_url(restaurant))
      else
        flash[:notice] = 'Saved your updates!'
        redirect_to edit_restaurant_url(restaurant)
      end
    else
      @form_fields = @topic.form_attribute.fields
      flash[:notice] = 'Failed to store your updated!'
      @restaurant = restaurant
      render :action => :edit
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

  def update_record
    redirect_to edit_restaurant_url(:id => current_user.restaurants.by_topic(@topic.id).first.id)
  end

end
