require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @request.host = Topic.default.subdomain + '.abc.com'
  end

  def test_user_registration
    user_count_was = User.count

    post :create, :user => {
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
  end

end
