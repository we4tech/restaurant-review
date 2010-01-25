# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  include ApplicationHelper
  include UrlOverrideHelper

  #include ExceptionNotifiable
  
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout 'fresh'
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  filter_parameter_logging :fb_sig_friends, :password

  before_filter :detect_topic_or_forward_to_default_one

  protected
    def log_last_visiting_time
      if current_user
        @user_log = current_user.user_logs.by_topic(@topic.id).first
        if @user_log
          @user_log.update_attribute(:updated_at, Time.now)
        else
          @user_log = UserLog.create(:user_id => current_user.id, :topic_id => @topic.id)
        end
      end
    end

    def log_new_feature_visiting_status
      @dont_show_new_features = []

      if defined?(NEW_FEATURES)
        cookie = cookies[:new_feature]

        if cookie.nil?
          cookies[:new_feature] = {
            :value => '',
            :expires => 1.year.from_now
          }
        else
          key = "#{params[:controller]}_#{params[:action]}"
          NEW_FEATURES.each do |feature_name, feature|
            if !cookie.include?(feature_name.to_s) && feature[:unless_visited_on].include?(key)
              cookies[:new_feature] = {
                :value => "#{cookie}|#{feature_name.to_s}",
                :expires => 1.year.from_now
              }
              @dont_show_new_features << feature_name
            elsif cookie.include?(feature_name.to_s)
              @dont_show_new_features << feature_name
            end
          end
        end
      end
    end
  
end
