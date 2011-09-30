class ImagesController < ApplicationController

  before_filter :login_required, :except => [:show, :mobile_upload]
  skip_before_filter :verify_authenticity_token, :only => [:mobile_upload]

  caches_action :show, :cache_path => Proc.new { |c|
    c.cache_path(c, [:id])
  }, :if => Proc.new { |c| !c.send(:mobile?) }

  def create
    page_context :list_page
    @multi_images = prepare_image_object

    if @multi_images.saved_all?
      class_name = determine_mapping_class_name
      @multi_images.groups.each do |group|
        cleanup_image_relation(class_name, group)
      end
      object_id, field_name, return_url = create_image_relation(class_name)

      flash[:notice] = 'Successfully added your image!'
      if params[:fb_share_off].nil? && current_user.share_on_facebook? && field_name == :restaurant_id
        redirect_to facebook_publish_url('new_image', @multi_images.images.first.id, :restaurant_id => object_id, :next_to => return_url)
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
    page_context :list_page
    @image = Image.find(params[:id].to_i)
    if_permits?(@image) do
      @restaurant = @image.discover_relation_with_any
      if @restaurant
        render_view('images/edit')
      end
    end
  end

  def update
    page_context :list_page
    @image = Image.find(params[:id].to_i)
    if_permits?(@image) do
      attributes = params[:image]
      attributes.delete(:user_id)
      attributes.delete(:restaurant_id)
      attributes.delete(:parent_id)
      attributes.delete(:topic_id)
      if @image.update_attributes(attributes)
        notify :success, params[:ref].present? ? params[:ref] : :back
      else
        notify :failure, params[:ref].present? ? params[:ref] : :back
      end
    end
  end

  def show
    page_context :details_page
    @image = Image.find_by_id(params[:id].to_i)
    @cached = true

    if @image
      @related_object = @image.discover_relation_with_any
      if @related_object
        @site_title = @image.caption.present? ? "#{@related_object.name} - #{@image.caption[0..20]}" : "#{@related_object.name} - picture"
      else
        @site_title = @image.caption.present? ? @image.caption : 'Image'
      end
      #render_view('images/show', :inner => true)
    else
      flash[:notice] = 'Image not found'
      redirect_to root_url
    end
  end

  def show_or_hide
    image = Image.find(params[:id].to_i)
    if image.update_attribute(:display, !image.display?)
      notify :success, :back
    else
      notify :failure, :back
    end
  end

  def set_for_section
    image = Image.find(params[:id])
    tag = Tag.find(params[:tag_id])

    if image && tag
      related_item = image.discover_relation_with_any
      if related_item && related_item.is_a?(Restaurant)

        # Add this restaurant as editor picked
        tag.update_attribute :section_data, [related_item.id]

        # Flag this image as 'section'
        image.update_relations related_item, :group => 'section'

        flash[:success] = 'This image is set as section picture'
      end
    else
      flash[:notice] = 'No section tag was selected.'
    end

    redirect_to :back
  end

  #
  # Find specific restaurant and use 1 as a default user
  # Create new image object and assign with it.
  #
  def mobile_upload
    self.current_user = User.find(1)
    @multi_images = prepare_image_object

    if @multi_images.saved_all?
      class_name = determine_mapping_class_name
      @multi_images.groups.each do |group|
        cleanup_image_relation(class_name, group)
      end
      object_id, field_name, return_url = create_image_relation(class_name)

      render :text => 'Successfully added your image!'
    else
      render :text => 'Failed to add your image!'
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

  def create_image_relation(class_name)
    object_type, object_id, field_name, return_url = determine_object_id_field_and_return_url

    @multi_images.each do |image|
      class_name.create({
                          :image_id => image.id,
                          :model => object_type,
                          :topic_id => @topic.id,
                          :group => image.group,
                          :user_id => current_user.id,
                        }.merge({field_name => object_id}))
    end

    return object_id, field_name, return_url
  end

  def cleanup_image_relation(class_name, group)
    if params[:override]
      other_options = {}

      if params[:restaurant_id].to_i > 0
        other_options[:restaurant_id] = params[:restaurant_id].to_i
      end

      existing_relation = class_name.first(:conditions => {
        :topic_id => @topic.id,
        :model => Restaurant.name,
        :group => group,
        :user_id => current_user.id}.merge(other_options))
      if existing_relation
        existing_relation.image.destroy
        existing_relation.destroy
      end
    end
  end

  def prepare_image_object
    multi_images = MultiImage.new(params[:multi_image])
    multi_images.user = current_user
    multi_images.topic_id = @topic.id

    multi_images
  end

  def determine_object_id_field_and_return_url
    object_type = Restaurant.name
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

    elsif params[:product_id]
      field_name = :product_id
      object_id = params[:product_id].to_i

    elsif params[:topic_event_id]
      field_name = :topic_event_id
      object_id = params[:topic_event_id]
      object_type = TopicEvent.name
      return_url = edit_event_url(object_id)
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

    return object_type, object_id, field_name, return_url
  end

  def determine_mapping_class_name
    relate_through = params[:relate_through]
    if relate_through && restaurant_author?
      determine_mapping_class_from(relate_through)
    else
      determine_mapping_class_name_by_params
    end
  end

  def determine_mapping_class_from(relate_through)
    case relate_through.to_s
      when 'related_image'
        RelatedImage
      when 'contributed_image'
        ContributedImage
    end
  end

  def restaurant_author?
    if (restaurant_id = params[:restaurant_id].to_i) > 0
      return Restaurant.find(restaurant_id).author?(current_user)
    end

    false
  end

  def determine_mapping_class_name_by_params
    if (restaurant_id = params[:restaurant_id].to_i) > 0
      if current_user.id != Restaurant.find(restaurant_id).user_id
        return ContributedImage
      end
    end

    RelatedImage
  end

end
