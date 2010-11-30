class Tag < ActiveRecord::Base

  belongs_to :topic
  has_many :tag_mappings, :dependent => :destroy
  has_many :restaurants, :through => :tag_mappings

  has_many :tag_group_mappings, :dependent => :destroy
  has_many :tag_groups, :through => :tag_group_mappings

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :topic_id

  after_save { TagGroup::update_caches! }
  after_destroy { TagGroup::update_caches! }

  default_scope :order => 'name ASC'
  named_scope :featurable, lambda { |topic_id| {:conditions => {:feature_enlist => true, :topic_id => topic_id}} }

  def cloud_size(factor, max_hit_count, min_hit_count)
    if tag_mappings_count > min_hit_count
      (factor * (tag_mappings_count - min_hit_count)) / (max_hit_count - min_hit_count)
    else
      1
    end
  end

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

end
