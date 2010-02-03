require 'test_helper'

class AddNewRestaurantTest < ActionController::IntegrationTest
  fixtures :all

  def test_add_new_restaurant
    login(users(:hasan))

    # Load new form
    get new_restaurant_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain), {}

    assert_response :success
    assert_not_nil assigns(:restaurant)

    # Post for creating new restaurant
    before_new_restaurant_saved = Restaurant.count

    # Validation error should be raised
    post restaurants_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain),
        :restaurant => {
            :name => '',
            :description => 'Description text',
            :address => 'address, dhaka'}
    assert_response :success
    assert_equal false, assigns(:restaurant).errors.empty?
    assert_not_nil assigns(:restaurant).errors.on(:name)

    # Successfully create new restaurant
    post restaurants_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain),
        :restaurant => {
            :name => 'test restaurant',
            :description => 'Description text',
            :address => 'address, dhaka'}

    assert_equal before_new_restaurant_saved + 1, Restaurant.count

    # Unique name validation error should be raised
    post restaurants_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain),
        :restaurant => {
            :name => 'test restaurant',
            :description => 'Description text',
            :address => 'address, dhaka'}
    assert_response :success
    assert_equal false, assigns(:restaurant).errors.empty?
    assert_not_nil assigns(:restaurant).errors.on(:name)
    assert_match /already been taken/, assigns(:restaurant).errors.on(:name)
  end

  def test_update_restaurant
    login(users(:hasan))

    # Update an existing item
    get edit_restaurant_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain,
        :id => restaurants(:one).id)

    assert_response :success
    assert_not_nil assigns(:restaurant)
    assert_equal assigns(:restaurant).id, restaurants(:one).id

    # Update with new content
    old_restaurant = restaurants(:one)

    put restaurant_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain,
        :id => old_restaurant.id),
        :restaurant => {
            :name => new_name = 'new test restaurant',
            :description => new_description = 'new Description text',
            :address => new_address = 'new address, dhaka'}

    puts flash[:notice]
    assert_response :redirect

    reloaded_restaurant = Restaurant.find(old_restaurant.id)
    assert_not_equal reloaded_restaurant.name, old_restaurant.name
    assert_not_nil reloaded_restaurant.description, old_restaurant.description
    assert_not_nil reloaded_restaurant.address, old_restaurant.address

    # Go to restaurant page
    get restaurant_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain,
        :id => reloaded_restaurant.id)

    assert_response :success
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
