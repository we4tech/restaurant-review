class Topic < ActiveRecord::Base

  CACHES = {}

  serialize :site_labels

  has_many :contributed_images
  has_many :images
  has_many :related_images
  has_many :restaurants
  has_many :reviews
  has_one  :form_attribute

  validates_presence_of :name, :label
  after_save :set_default

  named_scope :recent, :order => 'created_at DESC'
  @@per_page = 20

  def self.default
    Topic.find_by_default(true)
  end

  def translate_label(p_text, p_options = {})
    caches = Topic::CACHES["key_#{self.id}"]
    if caches.nil?
      map = (self.site_labels || {})
      caches = {}; map.each{|label| caches["#{label['old']}#{label['group']}"] = label['new']}

      Topic::CACHES["key_#{self.id}"] = caches
    end

    caches["#{p_text}#{p_options[:group]}"]
  end

  private
    def set_default
      if read_attribute(:default)
        Topic.update_all('`default` = 0', ['id <> ?', read_attribute(:id)])
      end
    end

end
