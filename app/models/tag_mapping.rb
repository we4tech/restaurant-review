class TagMapping < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :restaurant
  belongs_to :user
  belongs_to :topic

  validates_uniqueness_of :tag_id, :scope => :restaurant_id
end
