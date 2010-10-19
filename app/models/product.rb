class Product < ActiveRecord::Base

  serialize :properties

  belongs_to :user
  belongs_to :restaurant
  belongs_to :topic

  has_many :related_images
  has_many :images, :through => :related_images

  validates_presence_of :name, :description, :price
  named_scope :image_attached,
              :include => [:related_images],
              :conditions => ['related_images.id IS NOT NULL']

  @@per_page = 6
  cattr_reader :per_page

  def author?(p_user)
    return p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
  end

  def reviews(type = :all)
    Review.send(type,
        :conditions => {
            :restaurant_id => self.restaurant_id,
            :attached_model => "product",
            :attached_id => self.id
        })
  end

end
