class TagGroup < ActiveRecord::Base

  belongs_to :topic

  has_many :tag_group_mappings, :dependent => :destroy
  has_many :tags, :through => :tag_group_mappings

  validates_presence_of :name
  validates_uniqueness_of :name

  @@per_page = 20
  cattr_accessor :per_page

  def self.of(name)
    TagGroup.find_by_name(name)
  end

end
