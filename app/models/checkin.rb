class Checkin < ActiveRecord::Base

  belongs_to :topic
  belongs_to :user, :counter_cache => true
  belongs_to :restaurant, :counter_cache => true
  belongs_to :topic_event, :counter_cache => true

end
