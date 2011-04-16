#
# Keep user activity track
# Kick out banned user and other features
#
module UserActivityMonitoringService

  def self.included(base)
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module ClassMethods

    def policy(method)
      before_filter method
    end

  end

  module InstanceMethods

    #
    # Don't let ip banned user get into the site
    # Retrieve all policies (currently we are not digging more into topic specific configuration)
    def keep_away_ip_banned_visitors
      policies = SitePolicy.of(:ip_banned)
      if policies && !policies.empty?
        policies.each do |policy|
          allowed = policy.allowed?(request.remote_addr)
          if not allowed
            render :text => 'You are not allowed to access this site! you are banned!! weeee! :) contact to why.did.you.banned.me@welltreat.us'
            return false
          end
        end
      end
    end
  end

end
