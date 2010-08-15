class Page < ActiveRecord::Base

  belongs_to :user
  belongs_to :restaurant

  named_scope :by_url, lambda { |url| {:conditions => {:url => url}} }

  def author?(p_user)
    return p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
  end

end
