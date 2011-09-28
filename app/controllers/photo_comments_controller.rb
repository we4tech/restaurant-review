class PhotoCommentsController < ApplicationController

  before_filter :login_required

  def create
    @photo_comment = PhotoComment.new(params[:photo_comment])
    @photo_comment.user_id = current_user.id

    if @photo_comment.save
      flash[:notice] = 'Successfully added your comment.'

      if current_user.share_on_facebook? && @photo_comment.any
        redirect_to facebook_publish_url(
            'new_photo_comment', @photo_comment.id,
            :next_to => forward_to_image_view_page(@photo_comment, true))
      else
        redirect_to :back
      end
    else
      flash[:notice] = 'Failed to add your comment.'
      redirect_to forward_to_image_view_page(
          @photo_comment, false)
    end
  end

  def destroy
    photo_comment = PhotoComment.find(params[:id].to_i)

    if_permits?(photo_comment) do
      if photo_comment.destroy
        flash[:notice] = 'Successfully removed a photo comment.'
      else
        flash[:notice] = 'Failed to remove a photo comment. perhaps you are not authorized or invalid request.'
      end
    end

    redirect_to :back
  end

  private
  def forward_to_image_view_page(photo_comment, append_timestamp)
    if params[:stuff_event_id]
      stuff_event_id = params[:stuff_event_id].to_i
      url_title = photo_comment.image.caption
      if url_title.nil? || url_title.blank?
        url_title = photo_comment.restaurant.name
      end

      options = {:page => params[:page]}
      options[:t] = Time.now.to_i if append_timestamp

      display_photo_url(
          url_title.parameterize,
          stuff_event_id, options)
    else
      image_url(photo_comment.image_id)
    end
  end
end
