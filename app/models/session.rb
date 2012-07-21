class Session
  attr_accessor :login, :password, :rember_me

  def initialize(attrs = {})
    attrs.each do |k, v|
      self.send :"#{k}=", v
    end
  end

  def authenticate
    @user = User.authenticate(self.login, self.password)
    self
  end

  def get_user
    @user
  end
end