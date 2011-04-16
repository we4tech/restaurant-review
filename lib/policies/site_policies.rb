module SitePolicies

  def self.included(base)
    base.send :include, IpRelatedPolicies
  end

  module IpRelatedPolicies

    def policy_ip_banned?(client_ip_address)
      if self.policy
        return false if self.policy.split(/,/).collect(&:strip).compact.include?(client_ip_address)
      end
      
      true
    end
  end
end