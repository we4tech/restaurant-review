class PremiumTemplate < ActiveRecord::Base

  GROUP_BANNER_IMAGE = 'banner_image'
  GROUP_FEATURE_IMAGE = 'feature_image'
  @@premium_host_maps = {}

  belongs_to :restaurant
  belongs_to :user
  has_many :premium_template_elements

  validates_presence_of :restaurant_id, :user_id, :name, :site_title, :template

  named_scope :published, :conditions => {:published => true}

  def author?(p_user)
    return p_user && p_user.id == self.user.id || (p_user && p_user.admin?)
  end

  def find_or_create_element(key)
    element = self.premium_template_elements.by_element_key(key.to_s).first

    if element.nil?
      PremiumTemplateElement.create(
          :premium_template => self,
          :user => self.user,
          :restaurant => self.restaurant,
          :element_key => key.to_s,
          :data => [])
    else
      element
    end
  end

  def self.match_host(host)
    if premium_template = @@premium_host_maps[host]
      return premium_template
    else
      PremiumTemplate.all(:conditions => 'hosts IS NOT NULL').each do |pt|
        hosts = pt.hosts.split(/,/).collect(&:strip).compact
        hosts.each do |pt_host|
          if pt_host == host
            @@premium_host_maps[host] = pt
            return pt
          elsif pt_host.match(/#{host}$/)
            @@premium_host_maps[host] = pt
            return pt
          end
        end
      end

      return nil
    end
  end

end
