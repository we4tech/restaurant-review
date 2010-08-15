class Topic < ActiveRecord::Base

  CACHES = {}

  serialize :site_labels
  serialize :modules

  has_many :contributed_images
  has_many :images
  has_many :related_images
  has_many :restaurants
  has_many :reviews
  has_many :tags
  has_many :tag_groups
  has_many :messages
  has_one  :form_attribute

  validates_presence_of :name, :label
  after_save :set_default
  after_save :clear_cache

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

  def subdomain
    self.name.gsub('_', '.')
  end

  private
    def clear_cache
      Topic::CACHES["key_#{self.id}"] = nil
    end

    def set_default
      if read_attribute(:default)
        Topic.update_all('`default` = 0', ['id <> ?', read_attribute(:id)])
      end
    end

end
