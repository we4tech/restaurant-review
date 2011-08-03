class Tag < ActiveRecord::Base

  serialize :section_data

  belongs_to :topic

  has_many :tag_mappings, :dependent => :destroy
  has_many :restaurants, :through => :tag_mappings

  has_many :tag_group_mappings, :dependent => :destroy
  has_many :tag_groups, :through => :tag_group_mappings

  # Name are unique based on *topic* scope,
  # because each topic can have the same name for tag.
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :topic_id

  # Update tag group related caches
  after_save { TagGroup::update_caches! }
  after_destroy { TagGroup::update_caches! }

  # All results will be by default sorted by *name* and in ascending order.
  default_scope :order => 'name ASC'

  # Return a list of restaurants which has *feature_enlist* as true
  named_scope :featurable, lambda { |topic_id| {
      :conditions => {
          :feature_enlist => true,
          :topic_id => topic_id
      }
  }}

  # Return a list of tags which has *as_section* as true,
  # it means these tags are used as a section
  named_scope :sections, :conditions => {:as_section => true}

  # Return the list of editor selected restaurants from the specific
  # tag with the defined *limit*
  def editor_selected(limit = 1)
    ids = nil

    if section_data
      case section_data
        when Array
          ids = section_data[0..(limit - 1)]
        when String
          ids = section_data.split('|')[0..(limit - 1)]
      end
    end

    if ids && !ids.empty?
      Restaurant.find(ids)
    else
      []
    end
  end

  # Return the list of editor selected restaurants if found otherwise
  # Return the list sorted by the top ratings.
  def editor_selected_or_top_rated(limit = 1)
    items = editor_selected(limit)
    if items && !items.empty?
      items
    else
      most_loved_restaurants(limit)
    end
  end

  #
  # Determine the tag cloud size based on the *factor*, *max_hit_count* and *min_hit_count*
  # Otherwise return 1
  def cloud_size(factor, max_hit_count, min_hit_count)
    if tag_mappings_count > min_hit_count
      (factor * (tag_mappings_count - min_hit_count)) / (max_hit_count - min_hit_count)
    else
      1
    end
  end

  #
  # Determine restaurants which has top LOVES count
  # Sort them in Descending order.
  def most_loved_restaurants(limit = 10)
    TagMapping.all(
        :joins => ['LEFT JOIN reviews ON reviews.restaurant_id = tag_mappings.restaurant_id',
                   'LEFT JOIN restaurants ON restaurants.id = tag_mappings.restaurant_id'],
        :select => 'tag_mappings.*, restaurants.*, count(reviews.restaurant_id) as most_loved',
        :group => 'reviews.restaurant_id',
        :order => 'most_loved DESC',
        :limit => limit,
        :conditions => {
          'tag_mappings.tag_id' => self.id,
          'tag_mappings.topic_id' => self.topic_id,
          'reviews.loved' => Review::LOVED}).collect(&:restaurant)
  end

  #
  # Return the list of restaurants which was reviewed by the specified *reviewer*
  def restaurants_not_reviewed_by(reviewer, limit = 5)
    TagMapping.all(
        :joins => ['LEFT JOIN reviews ON reviews.restaurant_id = tag_mappings.restaurant_id',
                   'LEFT JOIN restaurants ON restaurants.id = tag_mappings.restaurant_id',
                   'LEFT JOIN users ON reviews.user_id = users.id'],
        :select => 'tag_mappings.*, restaurants.*',
        :limit => limit,
        :group => 'reviews.restaurant_id',
        :conditions => ['tag_id = ? AND reviews.user_id <> ? AND restaurants.user_id <> ?',
                        self.id, reviewer.id, reviewer.id]).collect(&:restaurant)
  end

  # Return tag name with tag group name if exists
  def name_with_group
    group = self.tag_groups.first
    if group
      "#{group.name}: #{self.name}"
    else
      self.name
    end
  end

  def ==(another_tag)
    if another_tag.is_a?(Tag)
      self.id == another_tag.id || name.to_s.downcase == another_tag.name.to_s.downcase
    else
      false
    end
  end

  #
  # Create a new class to process imported tags from text file
  class ImportableTag
    SEPARATOR_TYPE = ['COMMA', 'LINE', 'TAB', 'SPACE', 'CUSTOM']

    attr_accessor :post_processing_code, :pre_processing_code, :separator_type,
                  :custom_separator, :data, :topic_id, :tag_objects, :tag_group_id,
                  :error

    def initialize(attributes = {})
      attributes.each do |key, value|
        __send__ "#{key}=".to_sym, value
      end
    end

    def pre_process!
      if pre_processing_code.present?
        @tags = @tags.collect{|tag| eval(pre_processing_code)}.compact
      end
    end

    def post_process!
      if post_processing_code.present?
        @tag_objects = @tag_objects.collect{|tag_object| eval(post_processing_code)}.compact
      end
    end

    def import!
      parse_uploaded_file!
      pre_process!
      keep_unique_only!

      create_or_find_tags!
      map_tags!

      post_process!

      @succeeded = true
    end

    def map_tags!
      if tag_group_id.present?
        tag_group_mappings = TagGroupMapping.find_all_by_tag_id_and_tag_group_id_and_topic_id(@tag_objects.collect(&:id), tag_group_id, topic_id)
        resolved_mappings = tag_group_mappings.collect{|tgm| "#{tgm.tag_id}#{tgm.tag_group_id}"}
        unresolved_mappings = @tag_objects.collect{|to| !resolved_mappings.include?("#{to.id}#{tag_group_id}") ? to : nil}.compact

        unresolved_mappings.each do |tag_object|
          TagGroupMapping.create(
              :tag_id => tag_object.id,
              :tag_group_id => tag_group_id,
              :topic_id => topic_id
          )
        end

      end
    end

    def keep_unique_only!
      @tags.uniq!
    end

    def parse_uploaded_file!
      @tags = sanitize(parse_tags)
    end

    def create_or_find_tags!
      @tag_objects = Tag.find_all_by_name_and_topic_id(@tags, topic_id)
      create_unresolved_tags!
    end

    def create_unresolved_tags!
      unresolved_tags = @tags.collect(&:downcase) - @tag_objects.collect{|to| to.name.downcase}
      unresolved_tags.each do |tag|
        tag_object = Tag.new(:name => tag, :topic_id => topic_id)
        if tag_object.save
          @tag_objects << tag_object
        end
      end
    end

    def sanitize(tags)
      tags.collect{|t| t.strip}
    end

    def parse_tags
      case separator_type.upcase
        when 'LINE' then data.readlines
        when 'COMMA' then data.readlines(',')
        when 'TAB' then data.readlines('\t')
        when 'SPACE' then data.readlines('\s')
        when 'CUSTOM' then data.readlines(custom_separator)
      end
    end

    def succeeded?
      @succeeded
    end
  end

end
