require 'test_helper'

class UserRegistrationTest < ActionController::IntegrationTest
  fixtures :all

  def test_register_user
    user_count_was = User.count

    post users_url(
        :host => 'test.com',
        :subdomain => Topic.default.subdomain),
         :user => {
             :login => login = "test#{rand}",
             :email => "#{login}@abc.com",
             :password => "abcdef",
             :password_confirmation => "abcdef"
         }

    user = assigns(:user)

    assert_equal user_count_was + 1, User.count
    assert ActionMailer::Base.deliveries.length > 0
    assert_equal 'active', user.state
    assert_not_nil user.activated_at
    assert_response :redirect
    
  end
end
