class ContributedImage < ActiveRecord::Base

  belongs_to :user
  belongs_to :restaurant
  belongs_to :image
  belongs_to :topic

  named_scope :recent, :order => 'created_at DESC'
  named_scope :by_group, lambda { |group| {:conditions => {:group => group}} }
  named_scope :sectioned, :conditions => {:group => 'section'}

end
