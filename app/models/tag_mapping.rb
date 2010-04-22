class TagMapping < ActiveRecord::Base
  belongs_to :tag, :counter_cache => true
  belongs_to :restaurant
  belongs_to :user
  belongs_to :topic
end
