class Restaurant < ActiveRecord::Base

  serialize :properties
  serialize :short_array
  serialize :long_array
  serialize :short_map
  serialize :long_map
  serialize :extra_notification_recipients

  belongs_to :user
  belongs_to :topic
  has_many :related_images, :order => 'created_at DESC', :dependent => :destroy
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

  validates_presence_of :name, :topic_id
  validates_uniqueness_of :name
  validate :form_attributes_required_fields

  # Full Text search integration
  is_indexed :fields => ['created_at', 'name', 'description', 'address',
                         'short_array', 'long_array',
                         {:field => 'lat', :function_sql => "RADIANS(?)"},
                         {:field => 'lng', :function_sql => "RADIANS(?)"}],
             :include => [{:association_name => 'topic', :field => 'id', :as => 'topic_id'}],
             :delta => true


  named_scope :recent, :order => 'created_at DESC'
  named_scope :by_topic, lambda{|topic_id| {:conditions => {:topic_id => topic_id}}}
  named_scope :featured, lambda{|topic_id| {:conditions => {:featured => true, :topic_id => topic_id}}}

  @@per_page = 20
  cattr_reader :per_page

  attr_accessor :hit_count

  NO_LIMIT = -1
  RATING_LIMIT = 5

  def author?(p_user)
    return p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
  end

  def selected_premium_template
    self.premium_templates.published.first || self.premium_templates.first
  end

  def located_in_map?
    lat.to_i > 0 && lng.to_i > 0
  end

  #
  # Retrieve most loved restaurants based on the highest number of 'loved' rate
  # Use +p_limit+ option to limit the row set.
  # If +-1+ is given it will limit the row sets based on class attribute +:per_page+
  #
  def self.most_loved(p_topic, p_limit = 5, p_offset = 0)
    limit = determine_row_limit_option(p_limit)

    reviews = Review.by_topic(p_topic.id).loved.find(:all, {
        :include => [:restaurant],
        :group => 'restaurant_id',
        :order => 'count(restaurant_id) DESC',
        :offset => p_offset,
        :limit => limit})
    reviews.collect(&:restaurant)
  end

  def self.count_most_loved(p_topic)
    Review.by_topic(p_topic.id).loved.count
  end

  def self.recently_reviewed(p_topic, p_limit = 5, p_offset = 0)
    limit = determine_row_limit_option(p_limit)

    reviews = Review.by_topic(p_topic.id).recent.find(:all, {
        :include => [:restaurant],
        :offset => p_offset,
        :limit => limit})
    reviews.collect{|r| r.restaurant}
  end

  def self.recently_added_pictures(p_limit = 5, p_offset = 0)
    limit = determine_row_limit_option(p_limit)

    images = Image.recent.find(:all, {
        :conditions => 'parent_id IS NULL',
        :order => 'images.created_at DESC',
        :offset => p_offset,
        :limit => limit})

    restaurants = images.collect do |image|
      image.contributed_images.first.restaurant if image.contributed_images.first
      image.related_images.first.restaurant if image.related_images.first
    end

    restaurants.compact
  end

  def self.count_recently_reviewed(p_topic)
    Review.by_topic(p_topic).count
  end

  def last_review
    reviews.find(:first, :order => 'id DESC')
  end

  def reviewed?(p_user, options = {})
    if p_user
      p_user.reviews.of_restaurant(self, options).count > 0
    end
  end

  def rand_image
    (all_images || []).rand
  end

  def all_images
    (images || []) + (other_images || [])
  end

  def self.find_tags_of(p_column, p_topic)
    self.find(:all,
              :select => "restaurants.#{p_column.to_s}, count(#{p_column.to_s}) as hit_count",
              :conditions => ["#{p_column.to_s} <> '' AND topic_id = ?", p_topic.id],
              :order => 'hit_count DESC',
              :group => p_column)
  end

  def rating_out_of(p_scale = 5.0)
    total_loves = self.reviews.loved.count.to_f
    total_reviews = self.reviews.count.to_f
    (total_loves / total_reviews) * p_scale
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
        modified_values = values.collect{|v| v.strip.blank? ? nil : v}.compact

        if attributes.empty?
          send("#{field}=", modified_values)
        else
          attributes[field] = modified_values
        end
      end
    end
  end

  private
    def self.determine_row_limit_option(p_limit)
      if p_limit == -1
        per_page
      else
        p_limit
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
            :user_id => self.user_id})
        if existing_record
          errors.add_to_base("Existing record found")
        end
      end
    end

end
