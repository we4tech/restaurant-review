class PhotoComment < ActiveRecord::Base

  belongs_to :image, :counter_cache => true
  belongs_to :restaurant
  belongs_to :topic_event
  belongs_to :user

  validates_presence_of :image_id, :user_id, :content
  validates_length_of :content, :minimum => 1

  named_scope :recent, :order => 'created_at DESC'
  named_scope :retrieve_only, lambda {|limit| {:limit => limit}}

  include CommonModel::Common
  include CommonModel::CommonTopModel

end
