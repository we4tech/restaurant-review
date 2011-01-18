class Review < ActiveRecord::Base

  HATED = 0
  LOVED = 1
  WANNA_GO = 2
  MODULE_DEFAULT_LIST_ITEMS = 4

  belongs_to :user
  belongs_to :restaurant
  belongs_to :topic
  belongs_to :topic_event

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

  validate :ensure_not_duplicate

  include CommonModel::Common
  include CommonModel::CommonTopModel

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

  protected
    def ensure_not_duplicate
      last_review = self.user.reviews.last
      if last_review && attribute_matches?(last_review, [
          :restaurant_id, :loved, :comment, :status,
          :topic_id, :attached_model, :attached_id])
        errors.add(:restaurant_id, 'Duplicate comment')
      end
    end

    def attribute_matches?(match_with, fields)
      fields.each do |field|
        if send(field) != match_with.send(field)
          return false
        end
      end
      
      true
    end

end
