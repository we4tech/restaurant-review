class StuffEvent < ActiveRecord::Base

  TYPE_NONE = 0
  TYPE_RESTAURANT = 1
  TYPE_REVIEW = 2
  TYPE_REVIEW_COMMENT = 3
  TYPE_RESTAURANT_UPDATE = 4
  TYPE_REVIEW_UPDATE = 5
  TYPE_RELATED_IMAGE = 6
  TYPE_CONTRIBUTED_IMAGE = 7

  cattr_reader :per_page
  @@per_page = 20

  belongs_to :user
  belongs_to :restaurant
  belongs_to :review
  belongs_to :review_comment
  belongs_to :image
  belongs_to :topic

end
