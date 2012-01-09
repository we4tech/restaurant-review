class TopicEvent < ActiveRecord::Base

  EVENT_TYPES_MAP = {
      'Food festival'           => 1,
      'Fair'                    => 2,
      'Inauguration party'      => 3,
      'Special day celebration' => 4,
      'Musical event'           => 5,
      'Magic show'              => 6,
      'Comedy show'             => 7,
      'Deal'                    => 8
  }

  IMAGE_GROUPS = {
      :default => nil,
      :banner  => 'banner'
  }

  serialize :description_fields
  serialize :daily_schedule_map

  validates_presence_of :name, :description, :address, :start_at, :end_at, :topic_id, :user_id

  belongs_to :user
  belongs_to :topic
  belongs_to :parent_event, :foreign_key => 'parent_event_id',
             :class_name                 => 'TopicEvent'
  has_many :dependent_events, :foreign_key => 'parent_event_id',
           :class_name                     => 'TopicEvent'
  has_many :related_images
  has_many :images, :through => :related_images
  has_many :reviews
  has_many :review_comments
  has_many :checkins
  has_many :photo_comments

  named_scope :by_topic, lambda { |topic_id| { :conditions => { :topic_id => topic_id } } }
  named_scope :open_events, lambda {
    {
        :conditions => ['suspended = ? AND completed = ? AND end_at > ?', false, false, Time.now.utc]
    }
  }

  named_scope :upcoming, :conditions => ['start_at < ? AND start_at > ? AND end_at > ?',
                                         (Time.now + 7.days).utc, Time.now.utc, Time.now.utc],
              :order                 => 'start_at DESC'

  named_scope :far_future, :conditions => ['start_at >= ?', (Time.now + 7.days).utc],
              :order                   => 'start_at DESC'

  named_scope :ongoing, :conditions => ['start_at < ? AND end_at > ?', Time.now.utc, Time.now.utc],
              :order                => 'start_at DESC'

  named_scope :recent, :conditions => ['end_at < ?', Time.now.utc],
              :order               => 'end_at DESC'

  @@per_page = 20
  cattr_reader :per_page

  include CommonModel::Common
  include CommonModel::ReviewModel
  include CommonModel::LocationModel
  include CommonModel::CheckinModel

  def tags
    []
  end

  def other_images
    self.images
  end

  def all_images
    self.images
  end

  def rand_image
    (all_images || []).rand
  end

  def image_attached?
    not all_images.empty?
  end

  def extra_notification_recipients
    []
  end

  def field(key)
    if description_fields.present? && description_fields.include?(key)
      description_fields[key]
    end
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

  class << self
    # Retrieve upcoming events (which are with in a week),
    # also retrieve on going events. Return total 5 events
    def exciting_events(topic, options = { })
      events = { }

      limit      = options[:limit] || 10
      upcoming   = self.upcoming.by_topic(topic.id).all(:limit => 5)
      ongoing    = self.ongoing.by_topic(topic.id).all(:limit => 5)
      preferred  = options[:preferred] || :none
      only       = options[:only] || []

      if upcoming.length < 5
        far_future = self.far_future.by_topic(topic.id).all(:limit => 5).reverse
        gap = 5 - upcoming.length
        gap.times.each { upcoming << far_future.shift }
        upcoming.compact!
      end

      events[:upcoming] = upcoming
      return events if :upcoming == preferred && !upcoming.empty?

      events[:ongoing] = ongoing
      return events if [:upcoming, :ongoing].include?(preferred) && !ongoing.empty?

      if only.present?
        if only.include?(:upcoming) && only.include?(:ongoing)
          return upcoming + ongoing

        elsif only.include?(:upcoming)
          return upcoming

        elsif only.include?(:ongoing)
          return ongoing
        end
      end

      both_events = upcoming + ongoing

      if both_events.length < limit
        recent          = self.recent.by_topic(topic.id).all(:limit => limit - both_events.length)
        events[:recent] = recent
        return events if [:upcoming, :ongoing, :recent].include?(preferred) && !recent.empty?

        both_events + recent
      else
        both_events
      end

      events
    end
  end

end
