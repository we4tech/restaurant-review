class RelatedImage < ActiveRecord::Base

  belongs_to :image
  belongs_to :restaurant
  belongs_to :user

end
