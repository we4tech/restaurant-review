class FacebookConnectController < ApplicationController

  before_filter :login_required

  RESTAURANT_ADDED_TEMPLATE_BUNDLE_ID = 194034588205
  RESTAURANT_UPDATED_TEMPLATE_BUNDLE_ID = 194054683205
  IMAGE_ADDED_TEMPLATE_BUNDLE_ID = 194071943205
  REVIEW_ADDED_TEMPLATE_BUNDLE_ID = 194088128205


  # TODO: Add flag on restaurant object, marking this was shared on FB
  def publish_story
    begin
      if current_user.facebook_session_exists?
        story_type = params[:story]
        facebook_session = build_facebook_session
        status = false

        case story_type
          when 'new_restaurant'
            restaurant_or_event = Restaurant.find(params[:id].to_i)
            status = publish_story_of_restaurant(RESTAURANT_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, restaurant_or_event)
          when 'updated_restaurant'
            restaurant_or_event = Restaurant.find(params[:id].to_i)
            status = publish_story_of_restaurant(RESTAURANT_UPDATED_TEMPLATE_BUNDLE_ID, facebook_session, restaurant_or_event)
          when 'new_image'
            image = Image.find(params[:id].to_i)
            restaurant_or_event = Restaurant.find(params[:restaurant_id].to_i)
            status = publish_story_on_image_added(IMAGE_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, restaurant_or_event, image)
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
            restaurant_or_event = Restaurant.find(params[:id]) || TopicEvent.find(params[:id])
            checkin = Checkin.find(params[:checkin_id])
            status = publish_checkin(facebook_session, restaurant_or_event, checkin)
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

  def publish_checkin(session, event_or_restaurant, checkin)
    api = FacebookGraphApi.new(session.session_key, session.user.id)
    link = event_or_restaurant_url(event_or_restaurant)

    publish_through_fb_checkin(api, event_or_restaurant, checkin, link) ||
        publish_story_of_checkin(RESTAURANT_ADDED_TEMPLATE_BUNDLE_ID, session, event_or_restaurant, link)
  end

  private

  def publish_through_fb_checkin(api, restaurant, checkin, link)
    begin
      # Find nearby location
      nearby_places = api.find_nearby_places(
          :center => [restaurant.lat, restaurant.lng].join(','),
          :distance => 1000,
          :limit => 1)
      nearby_place = nearby_places.present? ? nearby_places.first : nil

      # Publish through facebook
      if nearby_place
        case restaurant
          when Restaurant
            return create_fb_checkin(api, restaurant, checkin, nearby_place, link)
          when TopicEvent
            return create_fb_checkin(api, restaurant, checkin, nearby_place, link)
          else
            flash[:notice] = 'Not allowed check in type'
            return false
        end
      end
    rescue => e
      raise e if 'development' == RAILS_ENV
    end

    false
  end

  def create_fb_checkin(api, restaurant, checkin, nearby_place, link)
    begin
      checkin_id = api.check_in(api.uid, {
          :message => "Just checked in \"#{restaurant.name}\" nearby",
          :place => nearby_place['id'],
          :coordinates => {:latitude => restaurant.lat, :longitude => restaurant.lng}
      })

      # If check in is successful on server
      if checkin_id
        # Update fb reference on original check in object
        checkin.update_attributes(
            :fb_checkin_id => checkin_id, :fb_checkin => true)

        # Publish khadok.com's url using comment
        api.create_comment(session.user.id, {
            :checkin_id => checkin_id,
            :message => "www.khadok.com source - #{link}"
        })

        return true
      end
    rescue => e
      raise e if 'development' == RAILS_ENV
      return false
    end

    false
  end

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
    restaurant = p_review.reload.any
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

  def publish_story_of_checkin(p_bundle_id, p_facebook_session, restaurant, link, shared = false)
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
                'href' => link}})
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
    if sid.present? && uid.present?
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
