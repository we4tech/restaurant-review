class Review < ActiveRecord::Base
  belongs_to :user
  belongs_to :restaurant

  validates_presence_of :user_id

  named_scope :restaurant, lambda{|restaurant_id| {:conditions => {:restaurant_id => restaurant_id}}}
  named_scope :loved, :conditions => {:loved => 1}
end
