class Restaurant < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic
  has_many :related_images, :order => 'created_at DESC', :dependent => :destroy
  has_many :images, :through => :related_images, :dependent => :destroy
  has_many :contributed_images, :order => 'created_at DESC', :dependent => :destroy
  has_many :other_images, :through => :contributed_images, :source => :image, :dependent => :destroy
  has_many :reviews
  has_many :stuff_events
  has_many :subscribers, :source => :user, :through => :stuff_events

  validates_presence_of :name, :description, :address

  named_scope :recent, :order => 'created_at DESC'

  cattr_reader :per_page
  @@per_page = 20

  NO_LIMIT = -1

  def author?(p_user)
    return p_user && p_user.id == self.user.id
  end

  #
  # Retrieve most loved restaurants based on the highest number of 'loved' rate
  # Use +p_limit+ option to limit the row set.
  # If +-1+ is given it will limit the row sets based on class attribute +:per_page+
  #
  def self.most_loved(p_limit = 5, p_offset = 0)
    limit = determine_row_limit_option(p_limit)

    reviews = Review.loved.find(:all, {
        :include => [:restaurant],
        :group => 'restaurant_id',
        :order => 'count(restaurant_id) DESC',
        :offset => p_offset,
        :limit => limit})
    reviews.collect{|r| r.restaurant}
  end

  def self.count_most_loved
    Review.loved.count
  end

  def self.recently_reviewed(p_limit = 5, p_offset = 0)
    limit = determine_row_limit_option(p_limit)

    reviews = Review.recent.find(:all, {
        :include => [:restaurant],
        :offset => p_offset,
        :limit => limit})
    reviews.collect{|r| r.restaurant}
  end

  def self.recently_added_pictures(p_limit = 5, p_offset = 0)
    limit = determine_row_limit_option(p_limit)

    images = Image.recent.find(:all, {
        :conditions => 'parent_id IS NULL',
        :order => 'images.created_at DESC',
        :offset => p_offset,
        :limit => limit})

    restaurants = images.collect do |image|
      image.contributed_images.first.restaurant if image.contributed_images.first
      image.related_images.first.restaurant if image.related_images.first
    end

    restaurants.compact
  end

  def self.count_recently_reviewed
    Review.count
  end

  def last_review
    reviews.find(:first, :order => 'id DESC')
  end

  def reviewed?(p_user)
    if p_user
      reviews.count(:conditions => {:user_id => p_user.id}) > 0
    end
  end

  private
  def self.determine_row_limit_option(p_limit)
    if p_limit == -1
      per_page
    else
      p_limit
    end
  end

end
