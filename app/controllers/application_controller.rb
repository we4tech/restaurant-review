# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
#require 'user_activity_monitoring_helper'

class ApplicationController < ActionController::Base

  #
  # Monitor banned ip profile
  include UserActivityMonitoringService
  policy :keep_away_ip_banned_visitors

  #
  # Include exception notifier
  include ExceptionNotification::ExceptionNotifiable

  #
  # Render errors on the page for dev, test and staging environment
  if !['test', 'staging', 'development'].include?(Rails.env)
    alias :rescue_action_locally :rescue_action_in_public
  end

  #
  # Specially handle bad authentication token exception
  rescue_from ActionController::InvalidAuthenticityToken, :with => :bad_auth_token

  #
  # Specially handle 404 error
  rescue_from ActionController::RoutingError, :with => :four_o_four

  #
  # Be sure to include AuthenticationSystem in Application Controller instead
  include CacheHelper
  include AuthenticatedSystem
  include UsersHelper
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
  include PartialViewHelperHelper
  include TemplateServiceHelper
  include StuffEventsHelper

  #
  # Load all application helpers
  helper :all

  #
  # Forgery protection is turned on
  protect_from_forgery

  #
  # Default layout
  layout 'fresh'

  #
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  filter_parameter_logging :fb_sig_friends, :password

  #
  # Set before filters
  before_filter :set_cookie_domain
  before_filter :detect_premium_site_or_topic_or_forward_to_default_one
  before_filter :check_facebook_connect_session, :except => [:auth_destroy, :fb_auth_destroy]
  before_filter :detect_mobile_view
  before_filter :detect_locale
  before_filter :detect_fake_email
  before_filter :determine_rotatable_background_image

  protected

    #
    # Handle bad auth token exception
    def bad_auth_token
      logger.warn('Caught invalid authenticity request')
      flash[:notice] = 'Invalid authenticity token, please try again'
      redirect_to request.referer.present? ? request.referer : root_url
    end

    #
    # Handle file not found exception since it generates lotta log into server.
    def four_o_four
      render :text => 'File not found', :status => 404
    end

    #
    # Override default url option ie. add locale params etc.
    def default_url_options(options = {})

      # Force for url locale
      options[:l] = I18n.locale if !options.keys.include?(:l)
      determine_host! options

      # Force Content Format
      if defined?(params) && options[:format].nil? && params[:format]
        if !params[:format].to_s.match(/^ajax|asset/)
          options[:format] = params[:format]
        end
      end

      options
    end

    def determine_host! (options)
      # If ajax is request host, forcefully set different
      # topic sub domain as url host
      if request && !options.include?(:subdomain) && !options.include?(:host)
        host_parts = request.host.split('.')

        if (host_parts.first || '').match(/^ajax\d+$/)
          if @subdomain_routing_stop
            options[:subdomain] = 'www'
          else
            options[:subdomain] = @topic ? @topic.subdomain : nil
          end
        elsif @topic.user_subdomain?
          options[:subdomain] = 'www'
        elsif @topic
          options[:host] = @topic.public_host
        end
      end
    end

    #
    # Check whether the current user is authored (or allowed)
    # to perform action on the specific object
    def if_permits? (object)
      if object && object.author?(current_user)
        yield
      else
        flash[:notice] = 'You are not authorized!'
        redirect_to root_url
      end
    end

    #
    # Since we have allowed fake email address for those who has logged in through facebook.
    # Not allowing us to retrieve his email address. thus we don't know what's his email address is.
    # We use this *before filter* to detect such user and take them to their edit page so that they
    # can enter their valid email address.
    def detect_fake_email
      if logged_in?
        if current_user.fake_email?
          # Don't f**k with system urls ie. edit_user itself and user, logout and fb_logout
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

    @@background_images = []

    #
    # Determine rotatable background image by current time
    # ie. 0 means default image
    #     1-12 means 1 AM to 12 PM
    #     13-18 means 13 PM to 18 PM
    # Mention *:load_bg* for loading background image
    def determine_rotatable_background_image
      if @@background_images.empty? || params[:load_bg]
        @@background_images = load_background_images
      end

      @background_image = @@background_images["hour_#{Time.now.hour}"] || @@background_images[:default]
    end

    #
    # Load list of available background images from bg-pictures directory
    # based on their naming convention.
    def load_background_images
      hourly_image_files = {}

      Dir.glob(File.join(RAILS_ROOT, 'public', 'bg-pictures', '*.jpg')).each do |path|
        image_file = path.gsub(/#{File.join(RAILS_ROOT, 'public')}/, '')
        time_parts = image_file.split('/').last.split('.').first.split('-')

        # Determine default image
        if time_parts.length == 1 && time_parts.first == '0'
          hourly_image_files[:default] = image_file

        # Determine time range
        elsif time_parts.length == 2
          if time_parts.first.to_i < time_parts.last.to_i
            (time_parts.first.to_i..time_parts.last.to_i).each do |hour|
              hourly_image_files["hour_#{hour}"] = image_file
            end
          else
            (time_parts.first.to_i..24).each do |hour|
              hourly_image_files["hour_#{hour}"] = image_file
            end

            (0..time_parts.last.to_i).each do |hour|
              hourly_image_files["hour_#{hour}"] = image_file
            end
          end
        end
      end

      hourly_image_files
    end

end
