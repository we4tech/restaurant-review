# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
config.action_controller.asset_host = "http://asset%d.khadok.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

MAP_API_KEY = 'ABQIAAAAFNm78CTt6Ba6XsBkWZHE3hQJ1P_wMECDecVRk5GZ-2b28we_rhTU3P-5VoseZAtTkUwgI6Dz1x_jVA'

#require 'smtp-tls'

config.action_mailer.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => 587,
    :domain => "welltreat.us",
    :user_name => "support@welltreat.us",
    :password => "h3110w0r1d",
    :authentication => :plain,
    :enable_starttls_auto => true
}

config.action_mailer.default_url_options = {:host => 'www.khadok.com'}

if defined?(ActionController)
  ActionController::Base.session = {
    :key         => '_welltreatus_prod_v2',
    :secret      => 'f11cf195514c9f70d208c7860c97b77b2f2fa19cc1b7291d00e26c89530a75077146bc9f0ec4076af5c5fe9b74ec1a9a3de6158a1840712d801103022417cf67',
    :domain      => '.khadok.com'
  }
end
config.middleware.use "SetCookieDomain", ".khadok.com"

MAINTENANCE_IN_PROGRESS = false
