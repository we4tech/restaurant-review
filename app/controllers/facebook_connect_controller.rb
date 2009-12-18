class FacebookConnectController < ApplicationController

  RESTAURANT_ADDED_TEMPLATE_BUNDLE_ID = 194034588205
  RESTAURANT_UPDATED_TEMPLATE_BUNDLE_ID = 194054683205
  IMAGE_ADDED_TEMPLATE_BUNDLE_ID = 194071943205
  REVIEW_ADDED_TEMPLATE_BUNDLE_ID = 194088128205


  # TODO: Add flag on restaurant object, marking this was shared on FB
  def publish_story
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

    if params[:next_to]
      redirect_to params[:next_to]
    else
      redirect_to root_url
    end
  end

  private
  def publish_story_of_review(p_bundle_id, p_facebook_session, p_review)
    restaurant = p_review.reload.restaurant
    first_image = nil
    images = restaurant.images
    images = restaurant.other_images if images.empty?

    if images && !images.empty?
      first_image = images.rand
      first_image = {
        :type => 'image',
        :src => "#{root_url[0..root_url.length - 2]}#{first_image.public_filename(:large)}",
        :href => restaurant_url(restaurant)
      }
    end

    user = p_facebook_session.user
    FacebookerPublisher::deliver_publish_stream(
        user, user, {
        :attachment =>  {
          :name => "#{restaurant_review(p_review)} and reviewed '#{restaurant.name}'",
          :href => restaurant_url(restaurant),
          :caption => restaurant_review_stat(p_review),
          :description => remove_html_entities(p_review.comment),
          :media => [first_image].compact},
        :action_links => {
            'text' => 'add your review!',
            'href' => restaurant_url(restaurant)}});
  end

  def restaurant_review_stat(p_review)
    total_reviews_count = p_review.restaurant.reviews.count
    loved_count = p_review.restaurant.reviews.loved.count
    loved_percentage = (100 / total_reviews_count) * loved_count

    "#{total_reviews_count} review#{total_reviews_count > 1 ? 's' : ''}, #{loved_count} love#{total_reviews_count > 1 ? 's' : ''}!"
  end

  def restaurant_review(p_review)
    p_review.loved == 1 ? '&hearts; loved' : 'hated'
  end

  def publish_story_on_image_added(p_bundle_id, p_facebook_session, p_restaurant, p_image)
    user = p_facebook_session.user
    message = 'uploaded a new image of'
    if p_restaurant.user_id != p_image.user_id
      message = 'contributed by uploading a new image of'
    end

    FacebookerPublisher::deliver_publish_stream(
        user, user, {
        :attachment =>  {
          :name => "#{message} '#{p_restaurant.name}'",
          :href => restaurant_url(p_restaurant),
          :description => remove_html_entities(p_restaurant.description),
          :media => [{
            :type => 'image',
            :src => "#{root_url[0..root_url.length - 2]}#{p_image.public_filename(:large)}",
            :href => restaurant_url(p_restaurant)
          }]},
        :action_links => {
            'text' => 'add your review!',
            'href' => restaurant_url(p_restaurant)}});
  end

  def publish_story_of_restaurant(p_bundle_id, p_facebook_session, p_restaurant)
    images = p_restaurant.images
    images = p_restaurant.other_images if images.empty?
    if !images.empty?
      url_base = root_url[0..root_url.length - 2]
      images.each do |image|
        images << {
          :type => 'image',
          :src => "#{url_base}#{image.public_filename(:large)}",
          :href => restaurant_url(p_restaurant)
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
          :href => restaurant_url(p_restaurant),
          :caption => "Address: #{p_restaurant.address || 'no where!!'}",
          :description => remove_html_entities(p_restaurant.description),
          :media => images},
        :action_links => {
            'text' => 'add your review!',
            'href' => restaurant_url(p_restaurant)}});
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

  def remove_html_entities(p_str)
    (p_str || '').gsub(/<[\/\w\d\s="\/\/\.:'@#;\-]+>/, '')
  end
end
