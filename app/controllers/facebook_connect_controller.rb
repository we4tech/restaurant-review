class FacebookConnectController < ApplicationController

  before_filter :login_required

  RESTAURANT_ADDED_TEMPLATE_BUNDLE_ID = 194034588205
  RESTAURANT_UPDATED_TEMPLATE_BUNDLE_ID = 194054683205
  IMAGE_ADDED_TEMPLATE_BUNDLE_ID = 194071943205
  REVIEW_ADDED_TEMPLATE_BUNDLE_ID = 194088128205


  # TODO: Add flag on restaurant object, marking this was shared on FB
  def publish_story
    begin
      if current_user.facebook_sid.to_i > 0 && current_user.facebook_uid.to_i > 0
        story_type = params[:story]
        facebook_session = build_facebook_session
        status = false

        case story_type
          when 'new_restaurant'
            restaurant = Restaurant.find(params[:id].to_i)
            status = publish_story_of_restaurant(RESTAURANT_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, restaurant)
          when 'updated_restaurant'
            restaurant = Restaurant.find(params[:id].to_i)
            status = publish_story_of_restaurant(RESTAURANT_UPDATED_TEMPLATE_BUNDLE_ID, facebook_session, restaurant)
          when 'new_image'
            image = Image.find(params[:id].to_i)
            restaurant = Restaurant.find(params[:restaurant_id].to_i)
            status = publish_story_on_image_added(IMAGE_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, restaurant, image)
          when 'new_review'
            review = Review.find(params[:id].to_i)
            status = publish_story_of_review(REVIEW_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, review)
          when 'shared_review'
            review = Review.find(params[:id].to_i)
            status = publish_story_of_review(REVIEW_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, review, true)
          when 'updated_review'
            review = Review.find(params[:id].to_i)
            status = publish_story_of_review(REVIEW_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, review)
          when 'new_photo_comment'
            photo_comment = PhotoComment.find(params[:id].to_i)
            status = publish_story_of_photo_comment(facebook_session, photo_comment)
          when 'checkedin'
            restaurant = Restaurant.find(params[:id].to_i)
            status = publish_story_of_checkin(RESTAURANT_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, restaurant)
        end

        if status
          flash[:notice] = 'Successfully, shared with your facebook friends!'
        else
          flash[:notice] = 'Failed to share with your facebook friends!, please review your configuration!'
        end
      else
        flash[:notice] = 'No active facebook session found.'
      end
    rescue => e
      handle_fb_connect_error(e)
    end

    if params[:next_to]
      redirect_to params[:next_to]
    else
      redirect_to root_url
    end
  end

  def checkin
    if current_user.facebook_sid.to_i > 0 && current_user.facebook_uid.to_i > 0
      begin
        model_name = params[:model_name]
        model_id = params[:id]
        session = build_facebook_session

        api = FacebookGraphApi.new(session.session_key, session.user.id)

        case model_name
          when 'restaurant'
            restaurant = Restaurant.find(model_id)
            api.check_in('me', {
                :message => 'Just checked in',
                :place => 19292868552,
                :coordinates => {:latitude => restaurant.lat, :longitude => restaurant.lng}
            })

          when 'event'
            event = Restaurant.find(model_id)
        end
      rescue => e
        handle_fb_connect_error(e)
      end
    else
      flash[:notice] = 'No active facebook session found'
    end
  end

  private

  def handle_fb_connect_error(e)
    if e.is_a?(Facebooker::Session::PermissionError)
      User.find(current_user.id).update_attributes(
          :facebook_sid => 0, :facebook_uid => 0,
          :facebook_connect_enabled => false)
      flash[:notice] = "You didn't authorize restaurant review application to share your review with facebook friends."
    else
      flash[:notice] = "Unknown error - '#{e.type.name}' occurred."
      logger.warn(e)
    end

    if 'development' == RAILS_ENV
      raise e
    end
  end

  def publish_story_of_review(p_bundle_id, p_facebook_session, p_review, shared = false)
    restaurant = p_review.reload.restaurant
    link = restaurant_long_route_url(
        :topic_name => p_review.topic.subdomain,
        :name => restaurant.name.parameterize.to_s,
        :id => restaurant.id,
        :format => :html
    )

    attached_images = []
    images = restaurant.images
    images = restaurant.other_images if images.empty?

    url = "http://#{request.host}"
    if images && !images.empty?
      images.shuffle.each do |image|
        attached_images << {
            :type => 'image',
            :src => "#{url}#{image.public_filename(:large)}",
            :href => link
        }
      end
    end

    user = p_facebook_session.user
    FacebookerPublisher::deliver_publish_stream(
        user, user, {
            :attachment => {
                :name => "#{restaurant_review_title(p_review, shared)} '#{restaurant.name}'",
                :href => link,
                :caption => restaurant_review_stat(p_review),
                :description => remove_html_entities(restaurant_review_content(p_review, shared)),
                :media => attached_images},
            :action_links => {
                'text' => 'Add your review!',
                'href' => link}});
  end

  def publish_story_of_checkin(p_bundle_id, p_facebook_session, restaurant, shared = false)
    link = restaurant_long_route_url(
        :topic_name => restaurant.topic.subdomain,
        :name => restaurant.name.parameterize.to_s,
        :id => restaurant.id,
        :format => :html
    )

    attached_images = []
    images = restaurant.images
    images = restaurant.other_images if images.empty?

    url = "http://#{request.host}"
    if images && !images.empty?
      images.shuffle.each do |image|
        attached_images << {
            :type => 'image',
            :src => "#{url}#{image.public_filename(:large)}",
            :href => link
        }
      end
    end

    user = p_facebook_session.user
    FacebookerPublisher::deliver_publish_stream(
        user, user, {
            :attachment => {
                :name => "Checked in '#{restaurant.name}'",
                :href => link,
                :caption => restaurant_review_stat(restaurant),
                :description => '',
                :media => attached_images},
            :action_links => {
                'text' => 'Add your review!',
                'href' => link}});
  end

  def restaurant_review_content(review, shared = false)
    if !shared
      "#{review.comment}"
    else
      "Reviewed by #{review.user.login}: #{review.comment}"
    end
  end

  def publish_story_of_photo_comment(facebook_session, photo_comment)
    restaurant = photo_comment.restaurant
    url = "http://#{request.host}"

    user = facebook_session.user
    FacebookerPublisher::deliver_publish_stream(
        user, user, {
            :attachment => {
                :name => "Added a comment on a image of '#{restaurant.name}'",
                :href => image_url(photo_comment.image_id),
                :caption => restaurant_review_stat(restaurant),
                :description => remove_html_entities(photo_comment.content),
                :media => [{
                    :type => 'image',
                    :src => "#{url}#{photo_comment.image.public_filename(:large)}",
                    :href => image_url(photo_comment.image_id)
                }]},
            :action_links => {
                'text' => 'Add your review!',
                'href' => restaurant_long_url(restaurant)}});
  end

  def collect_attached_images(restaurant)
    attached_images = []
    images = restaurant.images
    images = restaurant.other_images if images.empty?

    url = "http://#{request.host}"

    if images && !images.empty?
      images.shuffle.each do |image|
        attached_images << {
            :type => 'image',
            :src => "#{url}#{image.public_filename(:large)}",
            :href => link
        }
      end
    end

    attached_images
  end

  def publish_story_on_image_added(p_bundle_id, p_facebook_session, p_restaurant, p_image)
    link = restaurant_long_route_url(
        :topic_name => p_restaurant.topic.subdomain,
        :name => p_restaurant.name.parameterize.to_s,
        :id => p_restaurant.id,
        :format => :html
    )

    user = p_facebook_session.user
    message = 'uploaded a new image of'
    if p_restaurant.user_id != p_image.user_id
      message = 'shared a new image of'
    end

    url = "http://#{request.host}"
    FacebookerPublisher::deliver_publish_stream(
        user, user, {
            :attachment => {
                :name => "#{message} '#{p_restaurant.name}'",
                :href => link,
                :description => remove_html_entities(p_restaurant.description),
                :media => [{
                    :type => 'image',
                    :src => "#{url}#{p_image.public_filename(:large)}",
                    :href => link
                }]},
            :action_links => {
                'text' => 'Add your review!',
                'href' => link}});
  end

  def publish_story_of_restaurant(p_bundle_id, p_facebook_session, p_restaurant)
    link = restaurant_long_route_url(
        :topic_name => p_restaurant.topic.subdomain,
        :name => p_restaurant.name.parameterize.to_s,
        :id => p_restaurant.id,
        :format => :html
    )

    images = p_restaurant.images
    images = p_restaurant.other_images if images.empty?
    if !images.empty?
      url_base = "http://#{request.host}"
      images.each do |image|
        images << {
            :type => 'image',
            :src => "#{url_base}#{image.public_filename(:large)}",
            :href => link
        }
      end
    end

    verb = 'added'
    verb = 'updated' if p_bundle_id == RESTAURANT_UPDATED_TEMPLATE_BUNDLE_ID

    user = p_facebook_session.user
    FacebookerPublisher::deliver_publish_stream(
        user, user, {
            :attachment => {
                :name => "#{verb} '#{p_restaurant.name}'",
                :href => link,
                :caption => "Address: #{p_restaurant.address || 'no where!!'}",
                :description => remove_html_entities(p_restaurant.description),
                :media => images},
            :action_links => {
                'text' => 'Add your review!',
                'href' => link}});
  end

  def build_facebook_session
    session = Facebooker::Session.create(@topic.fb_connect_key.blank? ? Facebooker.api_key : @topic.fb_connect_key,
                                         @topic.fb_connect_secret.blank? ? Facebooker.secret_key : @topic.fb_connect_secret)
    sid = current_user.facebook_sid
    uid = current_user.facebook_uid
    if sid.to_i > 0 && uid.to_i > 0
      begin
        session.secure_with!(sid, uid)
      rescue
        current_user.update_attributes(:facebook_sid => 0, :facebook_uid => 0)
        return nil
      end
    end

    return session
  end

end
