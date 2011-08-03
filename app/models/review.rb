class Review < ActiveRecord::Base

  HATED                     = 0
  LOVED                     = 1
  WANNA_GO                  = 2
  MODULE_DEFAULT_LIST_ITEMS = 4

  belongs_to :user
  belongs_to :restaurant
  belongs_to :topic
  belongs_to :topic_event

  has_many :review_comments
  has_many :stuff_events, :dependent => :destroy

  validates_presence_of :user_id

  named_scope :of_restaurant, lambda { |restaurant, and_other|
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
  named_scope :by_topic, lambda { |topic_id| {:conditions => {:topic_id => topic_id}} }
  named_scope :attached_with, lambda { |options|
    {
        :conditions => options
    }
  }
  named_scope :exclude_wannago, :conditions => ['loved <> ?', Review::WANNA_GO]
  named_scope :by_week, lambda { |date|
    {:conditions => ['created_at >= ? AND created_at <= ?',
                     date.at_beginning_of_week, date.end_of_week]}
  }

  named_scope :by_users, lambda{ |ids|
    if ids && !ids.empty?
      { :conditions => ['reviews.user_id IN (?)', ids]}
    end
  }

  named_scope :most, lambda {
    {
        :select => 'reviews.*, count(reviews.restaurant_id) as reviews_count',
        :group => 'reviews.restaurant_id', :order => 'reviews_count DESC'
    }
  }

  named_scope :by_restaurant, lambda { |restaurant_id|
    { :conditions => {:restaurant_id => restaurant_id} }
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

  class << self

    # Retrieve list of leaders who have made more reviews.
    def leaders(topic, limit = 5, offset = 0)
      excluded_list = LeaderBoardExcludeList.reviewers.collect{|e| e.ref_id}
      excluded_list.empty? ? excluded_list << 0 : excluded_list

      top_reviewers = Review.all(
          :joins => [:user],
          :select => 'reviews.id, reviews.user_id, count(users.id) as pc',
          :group => 'users.id',
          :order => 'pc DESC',
          :conditions => ['topic_id = ? AND users.id NOT IN (?)', topic.id, excluded_list],
          :offset => offset,
          :limit => limit
      )

      reviewers = User.find(top_reviewers.collect{|tr| tr.user_id})
      leaders = []

      top_reviewers.each_with_index do |tr, index|
        leaders << [tr.pc, reviewers[index]]
      end

      leaders
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
