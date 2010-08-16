class Image < ActiveRecord::Base

  GROUP_MENU = 'food_menu'

  belongs_to :user
  belongs_to :topic
  has_many :related_images, :dependent => :destroy
  has_many :contributed_images, :dependent => :destroy
  has_many :stuff_events, :dependent => :destroy
  has_many :photo_comments

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

  attr_accessor :group

  def author?(p_user)
    p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
  end

  def discover_relation_with_restaurant
    applicable_keys = RelatedImage.new.attributes.keys.collect{|key| key if key.to_s.match(/_id/)}
    applicable_keys.delete('user_id')
    applicable_keys.delete('image_id')
    applicable_keys.compact!

    self.related_images.each do |related_image|
      related_object = detect_related_object(applicable_keys, related_image)
      if related_object
        return related_object
      end
    end

    applicable_keys = ContributedImage.new.attributes.keys.collect{|key| key if key.to_s.match(/_id/)}
    applicable_keys.delete('user_id')
    applicable_keys.delete('image_id')
    applicable_keys.delete('topic_id')
    applicable_keys.compact!
    
    self.contributed_images.each do |contb_image|
      related_object = detect_related_object(applicable_keys, contb_image)
      if related_object
        return related_object
      end
    end

    return nil
  end

  private
    def detect_related_object(applicable_keys, related_image)
      applicable_keys.each do |key|
        if related_image.send(key).to_i > 0
          if key != 'restaurant_id'
            model = key.to_s.gsub('_id', '').to_sym
            object = related_image.send(model)
            if object.respond_to?(:restaurant_id)
              return object.restaurant
            end
          else
            return related_image.restaurant
          end
        end
      end
    end
  
end
