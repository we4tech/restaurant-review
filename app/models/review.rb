class Review < ActiveRecord::Base

  HATED = 0
  LOVED = 1
  WANNA_GO = 2
  MODULE_DEFAULT_LIST_ITEMS = 4

  belongs_to :user
  belongs_to :restaurant
  belongs_to :topic
  has_many :review_comments
  has_many :stuff_events, :dependent => :destroy

  validates_presence_of :user_id

  named_scope :of_restaurant, lambda{|restaurant, and_other|
    {
        :conditions => {
            :restaurant_id => restaurant.id
        }.merge(and_other)
    }
  }
  named_scope :loved, :conditions => {:loved => LOVED}
  named_scope :hated, :conditions => {:loved => HATED}
  named_scope :wanna_go, :conditions => {:loved => WANNA_GO}
  named_scope :recent, :order => 'created_at DESC'
  named_scope :by_topic, lambda{|topic_id| {:conditions => {:topic_id => topic_id}}}
  named_scope :attached_with, lambda{|options|
    {
      :conditions => options
    }
  }

  def loved?
    self.loved == LOVED
  end

  def hated?
    self.loved == HATED
  end

  def wanna_go?
    self.loved == WANNA_GO
  end

  def attached?
    attached_id.to_i > 0
  end

  def attachment
    if attached?
      attached_model.camelize.constantize.find(attached_id)
    else
      nil
    end
  end

end
