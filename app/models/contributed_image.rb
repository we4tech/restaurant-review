class ContributedImage < ActiveRecord::Base

  belongs_to :user
  belongs_to :restaurant
  belongs_to :image

end
