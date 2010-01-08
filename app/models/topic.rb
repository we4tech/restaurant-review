class Topic < ActiveRecord::Base

  has_many :contributed_images
  has_many :images
  has_many :related_images
  has_many :restaurants
  has_many :reviews

  validates_presence_of :name, :label
  after_save :set_default

  named_scope :recent, :order => 'created_at DESC'
  @@per_page = 20

  def self.default
    Topic.find_by_default(true)
  end

  private
    def set_default
      if read_attribute(:default)
        Topic.update_all('`default` = 0', ['id <> ?', read_attribute(:id)])
      end
    end

end
