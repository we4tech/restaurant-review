class TopicEvent < ActiveRecord::Base

  EVENT_TYPES_MAP = {
      'Food festival' => 1,
      'Fair' => 2,
      'Inauguration party' => 3,
      'Special day celebration' => 4
  }

  IMAGE_GROUPS = {
      :default => nil,
      :banner => 'banner'
  }

  serialize :description_fields
  serialize :daily_schedule_map

  validates_presence_of :name, :description, :address, :start_at, :end_at, :topic_id, :user_id

  belongs_to :user
  belongs_to :topic
  belongs_to :parent_event, :foreign_key => 'parent_event_id',
             :class_name => 'TopicEvent'
  has_many :dependent_events, :foreign_key => 'parent_event_id',
           :class_name => 'TopicEvent'
  has_many :related_images
  has_many :images, :through => :related_images
  has_many :reviews
  has_many :review_comments

  named_scope :open_events, :conditions => {
      :suspended => false, :completed => false}

  @@per_page = 20
  cattr_reader :per_page

  
  include CommonModel::Common
  include CommonModel::ReviewModel
  include CommonModel::LocationModel

  def other_images
    self.images
  end

  def all_images
    self.images
  end

  def rand_image
    (all_images || []).rand
  end

  def extra_notification_recipients
    []
  end

  #
  # THIS function will be redesigned with we will have banner selection option
  # Current implementation will only take the last banner
  def selected_banner
    image_relations = self.related_images
    if image_relations && !image_relations.empty?
      banner_image = image_relations.by_group(IMAGE_GROUPS[:banner]).last
      if banner_image
        banner_image.image
      end
    else
      nil
    end
  end

end
