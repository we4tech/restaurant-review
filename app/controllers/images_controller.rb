class ImagesController < ApplicationController

  def create
    field_name = nil
    object_id = nil
    return_url = nil

    if params[:restaurant_id]
      object_id = Restaurant.find(params[:restaurant_id].to_i).id
      field_name = :restaurant_id
      return_url = edit_restaurant_url(object_id)
    elsif params[:user_id]
      object_id = current_user.id
      field_name = :user_id
      if current_user.image
        current_user.image.destroy
        current_user.related_image.destroy
      end
      return_url = edit_user_url(object_id)
    end

    @image_file = Image.new(params[:image])
    @image_file.user = current_user
    if params[:image]
      @group = params[:image][:group]
    end

    if @image_file.save
      RelatedImage.create({
        :image_id => @image_file.id,
        :model => Restaurant.name,
        :group => @group
      }.merge({field_name => object_id}))

      flash[:notice] = 'Successfully added your image!'
      if current_user.share_on_facebook? && field_name == :restaurant_id
        redirect_to facebook_publish_url('new_image', @image_file.id, :restaurant_id => object_id, :next_to => return_url)
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
      flash[:notice] = "You can't remove this image!"
    end

    redirect_to :back
  end

end
