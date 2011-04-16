require 'policies/site_policies'

class SitePolicy < ActiveRecord::Base

  belongs_to :topic
  belongs_to :restaurant
  belongs_to :user

  include SitePolicies

  class << self
    def of(name)
      self.all(:conditions => {:name => name.to_s})
    end
  end

  def allowed?(params)
    __send__("policy_#{name}?".to_sym, params)
  end

end
