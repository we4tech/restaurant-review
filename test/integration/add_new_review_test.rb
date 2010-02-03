require 'test_helper'

class AddNewRestaurantTest < ActionController::IntegrationTest
  fixtures :all

  def test_add_new_review
    login(users(:hasan))

    # Load new form
    restaurant = restaurants(:one)
    reviews_count_before_save = Review.count

    post reviews_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain),
        {:review => {
            :restaurant_id => restaurant.id,
            :comment => 'hola'}},
        {:referer => '/'}

    assert_response :redirect
    assert_equal reviews_count_before_save + 1, Review.count
    assert ActionMailer::Base.deliveries.length > 0
  end

  def test_update_an_existing_review
    login(users(:hasan))

    # Load new form
    restaurant = restaurants(:one)
    reviews_count_before_save = Review.count
    old_review = reviews(:one)

    put review_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain,
        :id => old_review.id),
        {:review => {
            :restaurant_id => restaurant.id,
            :comment => 'holaxx'}},
        {:referer => '/'}

    assert_response :redirect
    assert_equal reviews_count_before_save, Review.count
    assert_not_equal Review.find(old_review.id), old_review.comment
    assert 0, ActionMailer::Base.deliveries.length
  end

  def test_add_comment_on_review
    login(users(:hasan))

    # Add comment
    review_comments_before_save = ReviewComment.count
    review = reviews(:one)

    post review_comments_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain),
        :review_comment => {
            :review_id => review.id,
            :content => 'hola'}

    assert_response :redirect
    assert_equal review_comments_before_save + 1, ReviewComment.count
    assert ActionMailer::Base.deliveries.length > 0
  end

  private
    def login(user)
      post session_url(
          :host => 'test.com',
          :subdomain => Topic.default.subdomain),
          :login => user.login,
          :password => 'hasankhan'

      assert_response :redirect
      assert_match /successful/, flash[:notice]
    end
end
