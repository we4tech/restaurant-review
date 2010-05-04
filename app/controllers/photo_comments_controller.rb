class PhotoCommentsController < ApplicationController

  before_filter :login_required

  def create
    @photo_comment = PhotoComment.new(params[:photo_comment])
    stuff_event_id = params[:stuff_event_id].to_i
    @photo_comment.user_id = current_user.id

    if @photo_comment.save
      flash[:notice] = 'Successfully added your comment.'
      redirect_to forward_to_image_view_page(
          @photo_comment, stuff_event_id, true)
    else
      flash[:notice] = 'Failed to add your comment.'
      redirect_to forward_to_image_view_page(
          @photo_comment, stuff_event_id, false)
    end
  end

  def destroy
    photo_comment = PhotoComment.find(params[:id].to_i)
    if current_user && current_user.admin? && photo_comment.destroy
      flash[:notice] = 'Successfully removed a photo comment.'
    else
      flash[:notice] = 'Failed to remove a photo comment. perhaps you are not authorized or invalid request.'
    end

    redirect_to :back
  end

  private
    def forward_to_image_view_page(photo_comment, stuff_event_id, append_timestamp)
      url_title = photo_comment.image.caption
      if url_title.nil? || url_title.blank?
        url_title = photo_comment.restaurant.name
      end

      options = {:page => params[:page]}
      options[:t] = Time.now.to_i if append_timestamp

      display_photo_url(
          url_title.parameterize,
          stuff_event_id, options)
    end
end
