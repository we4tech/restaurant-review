require 'test_helper'

class UserChangePasswordTest < ActionController::IntegrationTest
  fixtures :all

  def setup
  end

  def test_change_password
    # Change password
    get process_reset_password_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain
    ), :email => users(:hasan).email
    assert_response :redirect
    assert ActionMailer::Base.deliveries.length > 0

    reloaded_user = User.find(users(:hasan).id)
    assert_not_nil reloaded_user.remember_token
    assert_not_nil reloaded_user.remember_token_expires_at

    # Request for showing form for new password
    get change_password_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain,
        :token => reloaded_user.remember_token)

    assert_response :success
    assert_not_nil assigns(:user)

    # Store new password
    get save_new_password_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain),
        :password => new_password = 'abcdef',
        :confirm_password => new_password,
        :token => reloaded_user.remember_token

    assert_response :redirect
    assert_redirected_to login_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain)

    # Ensure token is removed
    reloaded_user = User.find(reloaded_user.id)
    assert_nil reloaded_user.remember_token
    assert_nil reloaded_user.remember_token_expires_at

    # Try to login using the new password
    post session_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain),
        :login => reloaded_user.login,
        :password => new_password

    assert_response :redirect
    assert_match /successful/, flash[:notice]
  end
end
