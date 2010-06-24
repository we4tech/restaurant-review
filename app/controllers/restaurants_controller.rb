class RestaurantsController < ApplicationController

  before_filter :login_required, :except => [:show]
  before_filter :log_new_feature_visiting_status

  def new
    if topic_imposed_limit_allows?
      @restaurant = Restaurant.new
      @form_fields = @topic.form_attribute.fields
      @allow_image_upload = @topic.form_attribute.allow_image_upload
      @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
      @edit_mode = true
    else
      flash[:notice] = 'You already have a profile with us, you can update!'
      redirect_to edit_restaurant_url(current_user.restaurants.by_topic(@topic.id).first.id)
    end
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
      @edit_mode = true
      flash[:notice] = "Failed to store new #{@topic.name.humanize} information!"
      render :action => :new
    end
  end

  def show
    @restaurant = Restaurant.find(params[:id].to_i)
    @site_title = "#{@restaurant.name} #{@restaurant.address.blank? ? '' : "@ #{@restaurant.address}"} "
    @form_fields = @topic.form_attribute.fields
    @allow_image_upload = @topic.form_attribute.allow_image_upload
    @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload

    load_module_preferences
    @left_modules = [
        :render_tagcloud,
        :render_search,
        :render_most_lovable_places,
        :render_recently_added_places,
        :render_topic_box]
  end

  def edit
    restaurant = Restaurant.find(params[:id].to_i)

    if restaurant.author?(current_user)
      @form_fields = @topic.form_attribute.fields
      @allow_image_upload = @topic.form_attribute.allow_image_upload
      @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
      @edit_mode = true
      @restaurant = restaurant
    else
      flash[:notice] = "You are not authorized to edit this entry!"
      redirect_to root_url
    end
  end

  def update
    restaurant = Restaurant.find(params[:id].to_i)
    user_id = current_user.id

    # Don't change original author if super admin is performing this operation
    if current_user.admin?
      user_id = restaurant.user_id
    end

    if restaurant.author?(current_user)
      attributes = params[:restaurant].merge(
          :user_id => user_id, :topic_id => @topic.id)
      attributes[:long_array] ||= []
      attributes[:short_array] ||= []

      if restaurant.update_attributes(attributes)
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
        @edit_mode = true
        render :action => :edit
      end
    else
      flash[:notice] = "You are not authorized to edit this entry!"
      redirect_to root_url
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

  private
    def topic_imposed_limit_allows?
      form_attribute = @topic.form_attribute
      form_attribute && form_attribute.allows_more_entry?(@topic, current_user)
    end

end
