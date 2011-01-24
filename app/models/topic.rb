class Topic < ActiveRecord::Base

  CACHES = {}
  TEMPLATE_DIR = '_generated'
  @@topic_caches = {}
  @@topics_host_maps = {}

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
  has_many :topic_events
  has_one  :form_attribute

  validates_presence_of :name, :label
  after_save :set_default
  after_save :clear_cache

  named_scope :recent, :order => 'created_at DESC'
  named_scope :enabled, :conditions => {:enabled => true}
  
  @@per_page = 20

  SUBDOMAIN_CONTENT_TYPE = {
      'User profile page' => 1,
      'Tag page' => 2,
      'Restaurant page' => 3
  }

  # TODO: Setup domain matcher based on SUBDOMAIN content type configuration

  #
  # Retrieve the default topic
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

  #
  # Represent topic name into more subdomain computable name
  # ie. convert "some_sub_domain" => "some.sub.domain"
  def subdomain
    self.name.gsub('_', '.')
  end

  #
  # Retrieve configuration for the specific +bind_column+
  #
  # Parameters -
  #   +bind_column+ - this column must be database specific column
  #                   which are mapped over topic module editor
  def module_conf(bind_column)
    (self.modules && self.modules.reject{|m| m['bind_column'] != bind_column} || []).first
  end

  #
  # Determine the default host,
  # right now the implementation is based on the +self.host_list+ array pop
  def default_host
    host_list.first
  end

  #
  # To convert +self.hosts+ string into an array of hosts
  # Space and Comma will be used for splitting host string
  def host_list
    return @host_list if defined?(@host_list)

    if !self.hosts.blank?
      @host_list = self.hosts.split(/[,\s]+/).compact
    else
      @host_list = []
    end

    @host_list
  end

  #
  # Determine locale based on whether this topic is set as "default" or not.
  # Because except all default topics we will be using +"topic.name"_en|bn+ format
  def locale(locale)
    if default?
      locale.to_s
    else
      "#{self.name}_#{locale.to_s}"
    end
  end

  #
  # Determine public host based on if host is defined otherwise standard host with topic.subdomain
  def public_host_config
    config = {:host => 'welltreat.us', :subdomain => subdomain, :l => locale(:en)}
    if default_host
      config = {:host => default_host, :subdomain => 'www', :l => locale(:en)}
    end

    config
  end

  def public_host
    config = public_host_config
    "#{config[:subdomain]}.#{config[:host]}"
  end

  def public_url(secure = false)
    config = public_host_config
    "http#{secure ? 's' : ''}://#{config[:subdomain]}.#{config[:host]}?l=#{config[:l]}"
  end

  #
  # Retrieve topic of specified name
  # +THIS METHOD handles with CACHED data+ due to overwhelmed use potential,
  # we have used class variable to cache the list.
  def self.of(topic_name)
    topic_name.downcase!
    if (topic = @@topic_caches[topic_name])
      topic
    else
      populate_topic_caches
      @@topic_caches[topic_name]
    end
  end

  #
  # Retrieve the topic which matches with the specified +host+
  def self.match_host(host)
    host.downcase!
    if topic = @@topics_host_maps[host]
      return topic
    else
      Topic.enabled(:conditions => 'hosts IS NOT NULL').each do |t|
        t.host_list.each do |pt_host|
          pt_host.downcase!
          if pt_host == host
            @@topics_host_maps[host] = t
            return t
          elsif host.match(/#{pt_host}$/) || pt_host.match(/#{host}/)
            @@topics_host_maps[host] = t
            return t
          end
        end
      end

      return nil
    end
  end

  private
    def self.populate_topic_caches
      Topic.all.each do |topic|
        @@topic_caches[(topic.name || '').downcase] = topic
      end
      @@topic_caches
    end

    def clear_cache
      Topic::CACHES["key_#{self.id}"] = nil
    end

    def set_default
      if read_attribute(:default)
        Topic.update_all('`default` = 0', ['id <> ?', read_attribute(:id)])
      end
    end

end
