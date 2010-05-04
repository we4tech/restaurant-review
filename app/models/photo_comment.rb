class PhotoComment < ActiveRecord::Base

  belongs_to :image, :counter_cache => true
  belongs_to :restaurant
  belongs_to :user

  validates_presence_of :content
  validates_length_of :content, :minimum => 1

end
