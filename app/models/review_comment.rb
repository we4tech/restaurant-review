class ReviewComment < ActiveRecord::Base

  HATED = 0
  LOVED = 1
  WANNA_GO = 2

  belongs_to :topic
  belongs_to :review
  belongs_to :user
  belongs_to :restaurant
  has_many :stuff_events, :dependent => :destroy

  validates_presence_of :user_id, :topic_id, :restaurant_id, :topic_id, :content

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

  def can_delete?(p_time = Time.now)
    it_was_created = (Time.now - self.created_at) / 1.minute
    if it_was_created < 10 # ago
      return true
    else
      return false
    end
  end

  def author?(p_user)
    return p_user && p_user.id == self.user.id
  end

end
