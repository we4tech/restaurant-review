class FacebookConnectController < ApplicationController

  RESTAURANT_ADDED_TEMPLATE_BUNDLE_ID = 194034588205
  RESTAURANT_UPDATED_TEMPLATE_BUNDLE_ID = 194054683205
  IMAGE_ADDED_TEMPLATE_BUNDLE_ID = 194071943205
  REVIEW_ADDED_TEMPLATE_BUNDLE_ID = 194088128205


  # TODO: Add flag on restaurant object, marking this was shared on FB
  def publish_story
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

    if params[:next_to]
      redirect_to params[:next_to]
    else
      redirect_to root_url
    end
  end

  private
  def publish_story_of_review(p_bundle_id, p_facebook_session, p_review)
    restaurant = p_review.reload.restaurant
    attachements = {}
    if restaurant.images && !restaurant.images.empty?
      first_image = restaurant.images.first
      attachements = {
        :images => [
          :src => first_image.public_filename(:small),
          :href => restaurant_url(restaurant)
        ]}
    end

    p_facebook_session.publish_user_action(p_bundle_id, {
        :restaurant_url => restaurant_url(restaurant.id),
        :restaurant_name => restaurant.name,
        :restaurant_review => restaurant_review(p_review),
        :restaurant_stat => restaurant_review_stat(p_review),
        :restaurants_url => root_url}.merge(attachements), nil, p_review.comment)
  end

  def restaurant_review_stat(p_review)
    total_reviews_count = p_review.restaurant.reviews.count
    loved_count = p_review.restaurant.reviews.loved.count
    loved_percentage = (100 / total_reviews_count) * loved_count

    "#{total_reviews_count} reviews, #{loved_percentage}% loved &amp; #{100 - loved_percentage}% hated!"
  end

  def restaurant_review(p_review)
    p_review.loved == 1 ? '&hearts; loved' : 'hated'
  end

  def publish_story_on_image_added(p_bundle_id, p_facebook_session, p_restaurant, p_image)
    p_facebook_session.publish_user_action(p_bundle_id, {
        :restaurant_url => restaurant_url(p_restaurant.id),
        :restaurant_name => p_restaurant.name,
        :restaurants_url => root_url,
        :images => [
          :src => p_image.public_filename(:small),
          :href => restaurant_url(p_restaurant)
        ]}, nil, p_restaurant.description)
  end

  def publish_story_of_restaurant(p_bundle_id, p_facebook_session, p_restaurant)
    image_attachements = {}
    if p_restaurant.images && !p_restaurant.images.empty?
      images = []
      p_restaurant.images.each do |image|
        images << {'src' => image.public_filename(:small),
                   'href' => restaurant_url(p_restaurant.id)}
      end
      image_attachements[:images] = images
    end

    p_facebook_session.publish_user_action(p_bundle_id, {
        :restaurant_url => restaurant_url(p_restaurant.id),
        :restaurant_name => p_restaurant.name,
        :restaurants_url => root_url}.merge(image_attachements), nil, p_restaurant.description)

  end

  def build_facebook_session
    session = Facebooker::Session.create(Facebooker.api_key, Facebooker.secret_key)
    sid = current_user.facebook_sid
    uid = current_user.facebook_uid
    if sid.to_i > 0 && uid.to_i > 0
      session.secure_with!(sid, uid)
      return session
    else
      return nil
    end
  end
end
