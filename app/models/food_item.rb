class FoodItem < ActiveRecord::Base

  belongs_to :user
  belongs_to :restaurant
  belongs_to :food_item
  has_many :food_items
  has_one :related_image
  has_one :image, :through => :related_image

  serialize :related_objects

  validates_presence_of :name, :restaurant_id, :user_id

  def all_images
    [image]
  end
end
