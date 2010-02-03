require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def test_register_new_user
    user = User.new(
        :login => login = "test#{rand}",
        :email => "#{login}@abc.com",
        :password => "abcdef",
        :password_confirmation => "abcdef"
    )

    assert true, user.register!
    assert_equal 1, ActionMailer::Base.deliveries.length
    assert_equal 'active', user.state
    assert_not_nil user.activated_at

    user
  end

end
