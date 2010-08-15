class Message < ActiveRecord::Base

  TYPE_RECIPE = 1
  TYPE_NEWS = 2
  TYPE_SPECIAL_OFFER = 3
  TYPE_PRESS_COVERAGE = 4

  TYPES = [
      ['News', TYPE_NEWS],
      ['Recipe', TYPE_RECIPE],
      ['Special Offer', TYPE_SPECIAL_OFFER],
      ['Press Coverage', TYPE_PRESS_COVERAGE]
  ]

  serialize :related_objects

  validates_presence_of :title, :content

  belongs_to :topic
  belongs_to :user
  belongs_to :restaurant
  has_many :related_images
  has_many :images, :through => :related_images 

  default_scope :order => 'id DESC'
  named_scope :by_type, lambda { |type_id| {:conditions => {:type_id => type_id}} }

  def self.type_label(type_id)
    TYPES.collect{|t| t.first if t.last == type_id}.compact
  end

  def author?(p_user)
    return p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
  end
end
