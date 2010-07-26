class TagGroupMapping < ActiveRecord::Base

  belongs_to :topic
  belongs_to :tag
  belongs_to :tag_group

  validates_uniqueness_of :tag_id, :scope => :tag_group_id
end
