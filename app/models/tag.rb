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
  
end
