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
        when 'updated_review'
          review = Review.find(params[:id].to_i)
          status = publish_story_of_review(REVIEW_ADDED_TEMPLATE_BUNDLE_ID, facebook_session, review)
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
      if e.is_a?(Facebooker::Session::PermissionError)
        User.find(current_user.id).update_attributes(
            :facebook_sid => 0, :facebook_uid => 0,
            :facebook_connect_enabled => false)
        flash[:notice] = "You didn't authorize restaurant review application to share your review with facebook friends."
      else
        flash[:notice] = "Unknown error - '#{e.type.name}' occurred."
        logger.warn(e)
      end
    end

    if params[:next_to]
      redirect_to params[:next_to]
    else
      redirect_to root_url
    end
  end

  private
  def publish_story_of_review(p_bundle_id, p_facebook_session, p_review)
    restaurant = p_review.reload.restaurant
    link = restaurant_long_route_url(
        :topic_name => p_review.topic.subdomain,
        :name => restaurant.name.parameterize.to_s,
        :id => restaurant.id
    )

    attached_images = []
    images = restaurant.images
    images = restaurant.other_images if images.empty?

    url = root_url.gsub(/(\?l=#{I18n.locale.to_s})/, '')
    if images && !images.empty?
      images.shuffle.each do |image|
        attached_images << {
            :type => 'image',
            :src => "#{url[0..url.length - 2]}#{image.public_filename(:large)}",
            :href => link
        }
      end
    end

    user = p_facebook_session.user
    FacebookerPublisher::deliver_publish_stream(
        user, user, {
        :attachment =>  {
          :name => "#{restaurant_review(p_review)} '#{restaurant.name}'",
          :href => link,
          :caption => restaurant_review_stat(p_review),
          :description => remove_html_entities(p_review.comment),
          :media => attached_images},
        :action_links => {
            'text' => 'add your review!',
            'href' => link}});
  end

  def publish_story_on_image_added(p_bundle_id, p_facebook_session, p_restaurant, p_image)
    link = restaurant_long_route_url(
        :topic_name => p_restaurant.topic.subdomain,
        :name => p_restaurant.name.parameterize.to_s,
        :id => p_restaurant.id
    )

    user = p_facebook_session.user
    message = 'uploaded a new image of'
    if p_restaurant.user_id != p_image.user_id
      message = 'contributed by uploading a new image of'
    end

    url = root_url.gsub(/(\?l=#{I18n.locale.to_s})/, '')
    FacebookerPublisher::deliver_publish_stream(
        user, user, {
        :attachment =>  {
          :name => "#{message} '#{p_restaurant.name}'",
          :href => link,
          :description => remove_html_entities(p_restaurant.description),
          :media => [{
            :type => 'image',
            :src => "#{url[0..url.length - 2]}#{p_image.public_filename(:large)}",
            :href => link
          }]},
        :action_links => {
            'text' => 'add your review!',
            'href' => link}});
  end

  def publish_story_of_restaurant(p_bundle_id, p_facebook_session, p_restaurant)
    link = restaurant_long_route_url(
        :topic_name => p_restaurant.topic.subdomain,
        :name => p_restaurant.name.parameterize.to_s,
        :id => p_restaurant.id
    )

    images = p_restaurant.images
    images = p_restaurant.other_images if images.empty?
    if !images.empty?
      url = root_url.gsub(/(\?l=#{I18n.locale.to_s})/, '')
      url_base = url[0..url.length - 2]
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
        :attachment =>  {
          :name => "#{verb} '#{p_restaurant.name}'",
          :href => link,
          :caption => "Address: #{p_restaurant.address || 'no where!!'}",
          :description => remove_html_entities(p_restaurant.description),
          :media => images},
        :action_links => {
            'text' => 'add your review!',
            'href' => link}});
  end

  def build_facebook_session
    session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
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
