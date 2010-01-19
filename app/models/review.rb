class Review < ActiveRecord::Base

  HATED = 0
  LOVED = 1
  WANNA_GO = 2

  belongs_to :user
  belongs_to :restaurant
  belongs_to :topic
  has_many :review_comments

  validates_presence_of :user_id

  named_scope :restaurant, lambda{|restaurant_id| {:conditions => {:restaurant_id => restaurant_id}}}
  named_scope :loved, :conditions => {:loved => LOVED}
  named_scope :hated, :conditions => {:loved => HATED}
  named_scope :wanna_go, :conditions => {:loved => WANNA_GO}
  named_scope :recent, :order => 'created_at DESC'
  named_scope :by_topic, lambda{|topic_id| {:conditions => {:topic_id => topic_id}}}

  def loved?
    self.loved == LOVED
  end

  def hated?
    self.loved == HATED
  end

  def wanna_go?
    self.loved == WANNA_GO
  end

end
