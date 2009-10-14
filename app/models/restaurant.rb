class Restaurant < ActiveRecord::Base

  belongs_to :user
  has_many :related_images, :order => 'created_at DESC', :dependent => :destroy
  has_many :images, :through => :related_images, :dependent => :destroy
  has_many :reviews

  named_scope :recent, :order => 'created_at DESC'

  def author?(p_user)
    return p_user && p_user.id == self.user.id
  end

  def self.most_loved(p_limit = 5)
    reviews = Review.loved.find(:all, :include => [:restaurant], :group => 'restaurant_id', :order => 'count(restaurant_id) DESC', :limit => p_limit)
    reviews.collect{|r| r.restaurant}
  end
end
