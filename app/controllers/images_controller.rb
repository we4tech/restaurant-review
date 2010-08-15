class ImagesController < ApplicationController

  before_filter :login_required, :except => [:show]

  def create
    @image_file, @group = prepare_image_object

    if @image_file.save
      object_id, field_name, return_url = create_image_relation

      flash[:notice] = 'Successfully added your image!'
      if params[:fb_share_off].nil? && current_user.share_on_facebook? && field_name == :restaurant_id
        redirect_to facebook_publish_url('new_image', @image_file.id, :restaurant_id => object_id, :next_to => return_url)
      elsif return_url
        redirect_to return_url
      else
        redirect_to :back
      end
    else
      flash[:notice] = 'Failed to add your image!'
      redirect_to :back
    end
  end

  def destroy
    image = Image.find(params[:id].to_i)
    if image.author?(current_user) && image.destroy
      flash[:notice] = 'Successfully removed an image.'
    else
      restaurant_id = params[:restaurant_id].to_i
      if restaurant_id > 0
        restaurant = Restaurant.find(restaurant_id)
        if my_restaurant_and_user_contributed_image(restaurant, image) && image.destroy
          flash[:notice] = 'You have removed a user contributed image.'
        end
      end
    end

    if !flash[:notice]
      flash[:notice] = "You can't remove this image!"
    end

    redirect_to :back
  end

  def edit
    @image = Image.find(params[:id].to_i)
    if_permits?(@image) do
      @restaurant = @image.discover_relation_with_restaurant
      if @restaurant
        render_view('images/edit')
      end
    end
  end

  def update
    @image = Image.find(params[:id].to_i)
    if_permits?(@image) do
      attributes = params[:image]
      attributes.delete(:user_id)
      attributes.delete(:restaurant_id)
      attributes.delete(:parent_id)
      attributes.delete(:topic_id)
      if @image.update_attributes(attributes)
        notify :success, params[:ref]
      else
        notify :failure, params[:ref]
      end
    end
  end

  def show
    @image = Image.find(params[:id].to_i)
    @restaurant = @image.discover_relation_with_restaurant
    if @restaurant
      render_view('images/show')
    end
  end

  private
  def my_restaurant_and_user_contributed_image(restaurant, image)
    if restaurant.user_id == current_user.id
      contribution_map = restaurant.contributed_images.find(:first, :conditions => {:image_id => image.id})
      if contribution_map
        return true
      end
    end

    false
  end

  def create_image_relation
    class_name = determine_mapping_class_name
    object_id, field_name, return_url = determine_object_id_field_and_return_url

    class_name.create({
      :image_id => @image_file.id,
      :model => Restaurant.name,
      :topic_id => @topic.id,
      :group => @group,
      :user_id => current_user.id,
    }.merge({field_name => object_id}))

    return object_id, field_name, return_url
  end

  def prepare_image_object
    group = nil
    image_file = Image.new(params[:image])
    image_file.user = current_user
    image_file.topic_id = @topic.id
    if params[:image]
      group = params[:image][:group]
    end

    return image_file, group
  end

  def determine_object_id_field_and_return_url
    field_name = nil
    object_id = nil
    return_url = nil

    # Initial mapping
    if params[:restaurant_id]
      object_id = Restaurant.find(params[:restaurant_id].to_i).id
      field_name = :restaurant_id
      return_url = edit_restaurant_url(object_id)
    elsif params[:user_id]
      object_id = current_user.id
      field_name = :user_id
      if current_user.image
        current_user.image.destroy
        if current_user.reload.related_image
          current_user.related_image.destroy
        end
      end
      
      return_url = edit_user_url(object_id)
    end

    # Override mapping with :food_item_id
    if params[:food_item_id]
      food_item = FoodItem.find(params[:food_item_id].to_i)
      object_id = food_item.id
      field_name = :food_item_id
      if food_item.image
        food_item.image.destroy

        if food_item.reload.related_image
          food_item.related_image.destroy
        end
      end

      return_url = restaurant_food_items_path(food_item.restaurant)
    elsif params[:message_id]
      message = Message.find(params[:message_id].to_i)
      object_id = message.id
      field_name = :message_id
      return_url = edit_restaurant_message_path(message.restaurant, message)
    end

    if params[:return_to]
      return_url = params[:return_to]
    end

    return object_id, field_name, return_url
  end

  def determine_mapping_class_name
    if (restaurant_id = params[:restaurant_id].to_i) > 0
      if current_user.id != Restaurant.find(restaurant_id).user_id
        return ContributedImage
      end
    end

    return RelatedImage
  end

end
