class TagGroup < ActiveRecord::Base

  @@group_caches = {}

  belongs_to :topic

  has_many :tag_group_mappings, :dependent => :destroy
  has_many :tags, :through => :tag_group_mappings
  named_scope :by_topic, lambda{|topic_id| {:conditions => {:topic_id => topic_id}}}

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :topic_id
  after_save { TagGroup::update_caches! }
  after_destroy { TagGroup::update_caches! }

  @@per_page = 20
  cattr_accessor :per_page

  class << self
    def of(topic, name)
      TagGroup.find_by_topic_id_and_name(topic.id, name)
    end

    def update_caches!
      TagGroup.all.each do |tag_group|
        @@group_caches[tag_group.name.downcase] = tag_group.tags.collect(&:name)
      end
    end

    def tags_of(group)
      if @@group_caches.empty?
        update_caches!
      end

      tags = @@group_caches[group.to_s.downcase]
      if tags && !tags.empty?
        tags.collect(&:downcase)
      else
        []
      end
    end

    def separate_tags(group, all_tags)
      tags = self.tags_of(group)
      found_tags = []

      if tags && !tags.empty?
        all_tags.each do |t|
          found_tags << t if tags.include?(t.downcase)
        end
      end

      found_tags
    end
  end

  def most_loved_restaurants(limit = 2)
    TagMapping.all(
        :joins => ['LEFT JOIN reviews ON reviews.restaurant_id = tag_mappings.restaurant_id',
                   'LEFT JOIN restaurants ON restaurants.id = tag_mappings.restaurant_id'],
        :select => 'tag_mappings.*, restaurants.*, count(reviews.restaurant_id) as most_loved',
        :group => 'reviews.restaurant_id',
        :order => 'most_loved DESC',
        :limit => limit,
        :conditions => {
          'tag_mappings.tag_id' => self.tags.collect(&:id),
          'tag_mappings.topic_id' => self.topic_id,
          'reviews.loved' => Review::LOVED}).collect(&:restaurant)
  end

end
