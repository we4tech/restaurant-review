class PhotoComment < ActiveRecord::Base

  belongs_to :image, :counter_cache => true
  belongs_to :restaurant
  belongs_to :user

  validates_presence_of :image_id, :user_id, :content
  validates_length_of :content, :minimum => 1

  def author?(p_user)
    return p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
  end

end
