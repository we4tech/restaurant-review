class StuffEvent < ActiveRecord::Base

  TYPE_NONE = 0
  TYPE_RESTAURANT = 1
  TYPE_REVIEW = 2
  TYPE_REVIEW_COMMENT = 3
  TYPE_RESTAURANT_UPDATE = 4
  TYPE_REVIEW_UPDATE = 5
  TYPE_RELATED_IMAGE = 6
  TYPE_CONTRIBUTED_IMAGE = 7
  TYPE_CHECKIN = 8
  TYPE_PHOTO_COMMENT = 9

  cattr_reader :per_page
  @@per_page = 10

  belongs_to :user
  belongs_to :restaurant
  belongs_to :topic_event
  belongs_to :review
  belongs_to :review_comment
  belongs_to :image
  belongs_to :topic
  belongs_to :photo_comment, :foreign_key => :review_id

  named_scope :recent, :order => 'stuff_events.created_at DESC'
  named_scope :by_topic, lambda{|topic_id| {:conditions => {:topic_id => topic_id}}}

  named_scope :by_tags, lambda{|tag_ids|
    if tag_ids && !tag_ids.empty?
      { :include => {:restaurant => :tag_mappings},
        :conditions => ['tag_mappings.tag_id IN (?)', tag_ids]}
    end
  }

  named_scope :by_users, lambda{|ids|
    if ids && !ids.empty?
      { :conditions => ['stuff_events.user_id IN (?)', ids]}
    end
  }

  named_scope :by_restaurants, lambda{|ids|
    if ids && !ids.empty?
      { :include => :restaurant,
        :conditions => ['restaurants.id IN (?)', ids]}
    end
  }

  named_scope :exclude_users, lambda{|ids|
    if ids && !ids.empty?
      { :conditions => ['stuff_events.user_id NOT IN (?)', ids]}
    end
  }

  include CommonModel::Common
  include CommonModel::CommonTopModel

end
