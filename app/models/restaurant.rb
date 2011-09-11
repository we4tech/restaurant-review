class Restaurant < ActiveRecord::Base

  serialize :properties
  serialize :short_array
  serialize :long_array
  serialize :short_map
  serialize :long_map
  serialize :extra_notification_recipients

  belongs_to :user
  belongs_to :topic

  has_many :related_images, :include => [:image], :order => 'created_at DESC', :dependent => :destroy
  has_many :images, :through => :related_images, :dependent => :destroy
  has_many :contributed_images, :order => 'created_at DESC', :dependent => :destroy
  has_many :other_images, :through => :contributed_images, :source => :image, :dependent => :destroy
  has_many :reviews
  has_many :stuff_events, :dependent => :destroy
  has_many :subscribers, :source => :user, :through => :stuff_events
  has_many :tag_mappings, :dependent => :destroy
  has_many :tags, :through => :tag_mappings
  has_many :premium_templates
  has_many :pages
  has_many :messages
  has_many :food_items
  has_many :premium_service_subscribers
  has_many :products
  has_many :site_policies
  has_many :checkins

  validates_presence_of :name, :topic_id
  validates_uniqueness_of :name
  validate :form_attributes_required_fields

  # Full Text search integration
  is_indexed :fields  => ['created_at', 'name', 'description', 'address',
                          'short_array', 'long_array',
                          {:field => 'lat', :function_sql => "RADIANS(?)"},
                          {:field => 'lng', :function_sql => "RADIANS(?)"}],
             :include => [{:association_name => 'topic', :field => 'id', :as => 'topic_id'}],
             :delta   => true


  named_scope :recent, :order => 'created_at DESC'
  named_scope :by_topic, lambda { |topic_id| {:conditions => {:topic_id => topic_id}} }
  named_scope :featured, lambda { |topic_id| {:conditions => {:featured => true, :topic_id => topic_id}} }
  named_scope :by_users, lambda{ |ids|
    if ids && !ids.empty?
      { :conditions => ['restaurants.user_id IN (?)', ids]}
    end
  }

  # Enable filterable query chain
  #include FilterableQueryChainSupport
  #enable_filterable_query_chain

  @@per_page = 20
  cattr_reader :per_page

  attr_accessor :hit_count, :new_tags

  NO_LIMIT     = -1
  RATING_LIMIT = 5

  include CommonModel::Common
  include CommonModel::LocationModel

  # Return the list of images of the specified *group* and specified *limit*
  def images_of(group, limit = 0)
    relations = related_images.by_group(group)
    if relations && !relations.empty?
      relations[0..limit]
    else
      relations = contributed_images.by_group(group)
      if relations && !relations.empty?
        relations[0..limit]
      else
        nil
      end
    end
  end

  def selected_premium_template
    self.premium_templates.published.first || self.premium_templates.first
  end

  #
  # Retrieve most loved restaurants based on the highest number of 'loved' rate
  # Use +p_limit+ option to limit the row set.
  # If +-1+ is given it will limit the row sets based on class attribute +:per_page+
  #
  class << self
    def most_loved(p_topic, p_limit = 5, p_offset = 0)
      limit   = self.determine_row_limit_option(p_limit)

      reviews = Review.by_topic(p_topic.id).loved.all({
          :include => [:restaurant],
          :group   => 'restaurant_id',
          :order   => 'count(restaurant_id) DESC',
          :offset  => p_offset,
          :limit   => limit})
      reviews.collect(&:restaurant)
    end

    def most_loved_by_users(p_topic, users, p_limit = 5, p_offset = 0)
      limit   = self.determine_row_limit_option(p_limit)

      reviews = Review.by_topic(p_topic.id).loved.all({
          :include => [:restaurant],
          :group   => 'reviews.restaurant_id',
          :order   => 'count(reviews.restaurant_id) DESC',
          :offset  => p_offset,
          :conditions => ['reviews.user_id IN (?)', users.collect(&:id)],
          :limit   => limit})
      reviews.collect(&:restaurant).compact
    end

    # Retrieve most checkined places
    def most_checkined(topic, limit = 5, offset = 0)
      limit    = self.determine_row_limit_option(limit)

      checkins = Checkin.by_topic(topic.id).all(
          :include => {:restaurant => [:related_images]},
          :group   => 'restaurant_id',
          :order   => 'count(restaurant_id) DESC',
          :offset  => offset,
          :limit   => limit)
      checkins.collect(&:restaurant)
    end

    # Retrieve mostly checkined places by the specific users
    def most_checkined_by_users(topic, users, limit = 5, offset = 0)
      limit    = self.determine_row_limit_option(limit)

      checkins = Checkin.by_topic(topic.id).all(
          :include => [:restaurant],
          :group   => 'restaurant_id',
          :order   => 'count(restaurant_id) DESC',
          :conditions => ['checkins.user_id IN (?)', users.collect(&:id)],
          :offset  => offset,
          :limit   => limit)
      checkins.collect(&:restaurant)
    end

    def count_checkined_by_users(topic, users)
      Checkin.by_topic(topic.id).count(
          :include => [:restaurant],
          :conditions => ['checkins.user_id IN (?)', users.collect(&:id)])
    end

    def count_most_checkined(topic)
      Checkin.by_topic(topic.id).count
    end

    def count_most_loved(p_topic)
      Review.by_topic(p_topic.id).loved.count
    end

    def recently_reviewed(p_topic, p_limit = 5, p_offset = 0)
      limit   = determine_row_limit_option(p_limit)

      reviews = Review.by_topic(p_topic.id).recent.all(
          :include => [:restaurant, :topic_event],
          :offset  => p_offset,
          :limit   => limit)
      reviews.collect { |r| r.restaurant || r.topic_event }
    end

    def recently_added_pictures(p_limit = 5, p_offset = 0)
      limit       = determine_row_limit_option(p_limit)

      images      = Image.recent.find(:all, {
          :conditions => 'parent_id IS NULL',
          :order      => 'images.created_at DESC',
          :offset     => p_offset,
          :limit      => limit})

      restaurants = images.collect do |image|
        image.contributed_images.first.restaurant if image.contributed_images.first
        image.related_images.first.restaurant if image.related_images.first
      end

      restaurants.compact
    end

    def count_recently_reviewed(p_topic)
      Review.by_topic(p_topic).count
    end

    def find_tags_of(p_column, p_topic)
      self.find(:all,
                :select     => "restaurants.#{p_column.to_s}, count(#{p_column.to_s}) as hit_count",
                :conditions => ["#{p_column.to_s} <> '' AND topic_id = ?", p_topic.id],
                :order      => 'hit_count DESC',
                :group      => p_column)
    end

    # Determine hot of the week based on the given topic and date.
    # This is calculated based on the mostly reviewed places
    def hot_of_the_week(topic, date, type = :love)
      hot_items = []

      case type
        when :love
          hot_items = Review.by_topic(topic.id).by_week(date).all(
              :group  => 'restaurant_id',
              :select => 'reviews.restaurant_id, count(reviews.restaurant_id) as hits',
              :order  => 'hits DESC')

        when :checkin
          hot_items = Checkin.by_topic(topic.id).by_week(date).all(
              :group  => 'restaurant_id',
              :select => 'checkins.restaurant_id, count(checkins.restaurant_id) as hits',
              :order  => 'hits DESC')
      end

      if not hot_items.empty?
        hot_items.first.restaurant
      else
        nil
      end
    end

    # Retrieve the list of leaders who has been adding most
    # of the restaurants
    def leaders(topic, limit = 5, offset = 0)
      excluded_list = LeaderBoardExcludeList.explorers.collect{|e| e.ref_id}
      excluded_list.empty? ? excluded_list << 0 : excluded_list
      owners  = Restaurant.all(
          :select     => 'restaurants.id, restaurants.user_id, count(users.id) as pc',
          :joins      => [:user],
          :conditions => ['topic_id = ? AND users.id NOT IN (?)', topic.id, excluded_list],
          :group      => 'users.id',
          :order      => 'pc DESC',
          :limit      => limit,
          :offset     => offset
      )

      users   = User.find(owners.collect { |o| o.user_id })
      leaders = []

      owners.each_with_index do |o, i|
        leaders << [o.pc, users[i]]
      end

      leaders
    end

    def determine_row_limit_option(p_limit)
      if p_limit == -1
        per_page
      else
        p_limit
      end
    end
  end

  def last_review
    reviews.find(:first, :order => 'id DESC')
  end

  def reviewed?(p_user, options = {})
    if p_user
      p_user.reviews.of_restaurant(self, options).count > 0
    end
  end

  def sorted_reviews(conditions = {}, sorting_type = :by_most_comments)
    case sorting_type
      when :by_most_comments
        self.reviews.all(
            :select => 'reviews.*, count(review_comments.review_id) as comments_count',
            :joins => [:review_comments],
            :group => 'review_comments.review_id',
            :order => 'comments_count DESC',
            :conditions => conditions
        )
      else
        self.reviews
    end
  end

  def rand_image
    (all_images || []).rand
  end

  def all_images
    (images || []) + (other_images || [])
  end

  def image_attached?
    not all_images.empty?
  end

  def rating_out_of(p_scale = 5.0)
    total_loves   = self.reviews.loved.count.to_f
    total_reviews = self.reviews.count.to_f
    rate = (total_loves / total_reviews) * p_scale
    if rate.to_s == 'NaN'
      0
    else
      rate
    end
  end

  def apply_filters(filter_map, attributes = {})
    if filter_map && !filter_map.empty?
      filter_map.each do |filter, fields|
        method_name = 'filter_' + filter.to_s
        if respond_to?(method_name)
          send(method_name, (fields || '').split(/,/).collect(&:strip).compact, attributes)
        end
      end
    end
  end

  #
  # Filters Implementations
  # Filters are used for filtering special fields, such as trimming a
  # serializable array field.
  #
  def filter_check_empty_array_element(fields, attributes = {})
    attributes.stringify_keys!
    fields.each do |field|
      if attributes.empty?
        values = send(field)
      else
        values = attributes[field.to_s]
      end

      if values.is_a?(Array)
        modified_values = values.collect { |v| v.strip.blank? ? nil : v }.compact

        if attributes.empty?
          send("#{field}=", modified_values)
        else
          attributes[field] = modified_values
        end
      end
    end
  end

  #
  # Find associated tags which belongs to the specific tag group
  # if noting found from the specified tag group return an empty array.
  def tags_belongs_to(tag_group)
    found_tags     = []
    tag_group_tags = tag_group.tags.collect { |t| t.name.to_s.downcase }

    if self.long_array && !self.long_array.empty?
      found_tags = self.long_array.collect { |t| t if tag_group_tags.include?(t.to_s.downcase) }.compact
    else
      []
    end
  end

  protected
  def form_attributes_required_fields
    if topic && topic.form_attribute
      form_attributes = topic.form_attribute

      # Ensure record input limit match
      ensure_record_insert_limit_doesnt_exceeds(form_attributes)

      # Ensure required fields are maintained
      ensure_required_fields_are_not_empty(form_attributes)
    end
  end

  def ensure_required_fields_are_not_empty(form_attributes)
    form_attributes.fields.each do |field|
      if field['required'] == true || field['required'].to_i == 1
        if self.send(field['field']).nil? || self.send(field['field']).empty?
          errors.add(field['field'], "can't be blank")
        end
      end
    end
  end

  def ensure_record_insert_limit_doesnt_exceeds(form_attributes)
    if new_record? && form_attributes.record_insert_type == FormAttribute::SINGLE_RECORD
      existing_record = Restaurant.find(:first, :conditions => {
          :topic_id => self.topic_id,
          :user_id  => self.user_id})
      if existing_record
        errors.add_to_base("Existing record found")
      end
    end
  end

end
