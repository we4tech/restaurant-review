class Image < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic
  has_many :related_images, :dependent => :destroy
  has_many :contributed_images, :dependent => :destroy
  has_many :stuff_events, :dependent => :destroy

  has_attachment  :size => 0.megabyte..5.megabytes,
                  :content_type => :image,
                  :path_prefix => 'public/uploaded_images',
                  :storage => :file_system,
                  :thumbnails => {
                      :very_small => 'x40',
                      :small => '60x60',
                      :large => 'x200',
                      :very_large => 'x400',
                  }
  validates_as_attachment

  named_scope :recent, :order => 'created_at DESC'
  named_scope :by_topic, lambda{|topic_id| {:conditions => {:topic_id => topic_id}}}

  def author?(p_user)
    p_user && p_user.id == self.user.id || 1 == p_user.admin
  end
  
end
