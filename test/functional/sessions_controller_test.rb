require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  fixtures :users, :topics

  def setup
    @request.host = Topic.default.subdomain + '.abc.com'
  end

  def test_user_login
    post :create, :login => 'hasan', :password => 'hasankhan'

    assert_match /successful/, flash[:notice]
  end

end
