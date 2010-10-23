class TagGroup < ActiveRecord::Base

  @@group_caches = {}

  belongs_to :topic

  has_many :tag_group_mappings, :dependent => :destroy
  has_many :tags, :through => :tag_group_mappings

  validates_presence_of :name
  validates_uniqueness_of :name
  after_save { TagGroup::update_caches! }
  after_destroy { TagGroup::update_caches! }

  @@per_page = 20
  cattr_accessor :per_page

  def self.of(name)
    TagGroup.find_by_name(name)
  end

  def self.update_caches!
    TagGroup.all.each do |tag_group|
      @@group_caches[tag_group.name.downcase] = tag_group.tags.collect(&:name)
    end
  end

  def self.tags_of(group)
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

  def self.separate_tags(group, all_tags)
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
