class ContributedImage < ActiveRecord::Base

  belongs_to :user
  belongs_to :restaurant
  belongs_to :image
  belongs_to :topic

  named_scope :recent, :order => 'created_at DESC'

end
