# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include ExceptionNotification::ExceptionNotifiable

  if Rails.env != 'test' && Rails.env != 'development'
    alias :rescue_action_locally :rescue_action_in_public
  end

  # Be sure to include AuthenticationSystem in Application Controller instead
  include CacheHelper
  include AuthenticatedSystem
  include ApplicationHelper
  include UrlOverrideHelper
  include FacebookConnectHelper
  include MobileHelper
  include StringHelper
  include LocaleHelper
  include PremiumHelper
  include PremiumTemplatesHelper
  include SearchHelper
  include MultidomainCookieHelper

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout 'fresh'

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  filter_parameter_logging :fb_sig_friends, :password

  before_filter :set_cookie_domain
  before_filter :detect_premium_site_or_topic_or_forward_to_default_one
  before_filter :check_facebook_connect_session
  before_filter :detect_mobile_view
  before_filter :detect_locale
  before_filter :detect_fake_email

  protected

    def default_url_options(options = {})
      # Force for url locale
      options[:l] = I18n.locale if !options.keys.include?(:l)

      # If ajax is request host, forcefully set different
      # topic subdomain as url host
      if request
        host_parts = request.host.split('.')
        if (host_parts.first || '').match(/^ajax\d+$/)
          options[:subdomain] = @topic ? @topic.subdomain : nil
        end
      end

      options
    end

    def if_permits? (object)
      if object && object.author?(current_user)
        yield
      else
        flash[:notice] = 'You are not authorized!'
        redirect_to root_url
      end
    end

    def detect_fake_email
      if logged_in?
        if current_user.fake_email?
          if request.url != edit_user_url(current_user) &&
              request.url != user_url(current_user) &&
              request.url != logout_url &&
              request.url != fb_logout_url
            flash[:notice] = 'Please enter your email address'
            session[:fake_email] = true
            redirect_to edit_user_url(current_user)
          end
        end
      end
    end

    def authorize
      if !current_user || !current_user.admin?
        flash[:notice] = 'You are not authorized to access this url.'
        redirect_to root_url
      end
    end

    def notify(type, redirect)
      case type
        when :success
          flash[:success] = 'Successfully completed!'
          redirect_to redirect

        when :failure
          flash[:notice] = 'Failed to complete!'
          if redirect.is_a?(Symbol) && redirect != :back
            render :action => redirect
          else
            redirect_to redirect
          end
      end
    end

    def restaurant_review(p_review)
      if p_review.loved?
        '&hearts; loved and reviewed this place!'
      elsif p_review.hated?
        'hated and reviewed this place! '
      elsif p_review.wanna_go?
        'wanna go to '
      end
    end

    def restaurant_review_stat(p_review)
      restaurant = nil

      if p_review.is_a?(Review)
        restaurant = p_review.restaurant
      elsif p_review.is_a?(Restaurant)
        restaurant = p_review
      end

      total_reviews_count = restaurant.reviews.count
      loved_count = restaurant.reviews.loved.count
      "#{total_reviews_count} review#{total_reviews_count > 1 ? 's' : ''}, #{loved_count} love#{total_reviews_count > 1 ? 's' : ''}, #{restaurant.rating_out_of(5).round} out of 5 ratings!"
    end

    def remove_html_entities(p_str)
      (p_str || '').gsub(/<[\/\w\d\s="\/\/\.:'@#;\-]+>/, '')
    end

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
      host_parts = request.host.split(/\./)
      host = host_parts[(host_parts.length - 2)..host_parts.length].join('.')

      if defined?(NEW_FEATURES)
        cookie = cookies[:new_feature]

        if cookie.nil?
          cookies[:new_feature] = {
            :domain => host,
            :value => '',
            :expires => 1.year.from_now
          }
        else
          key = "#{params[:controller]}_#{params[:action]}"
          NEW_FEATURES.each do |feature_name, feature|
            if !cookie.include?(feature_name.to_s) && feature[:unless_visited_on].include?(key)
              cookies[:new_feature] = {
                :domain => host,
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
