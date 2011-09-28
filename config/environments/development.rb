# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the web server when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.action_controller.asset_host = "http://ajax%d.hadok.com"

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_mailer.delivery_method = :sendmail
config.action_mailer.default_url_options = {:host => 'hadok.com'}

# google map API key
MAP_API_KEY = 'ABQIAAAAFNm78CTt6Ba6XsBkWZHE3hRXwWGis4ehQYwFPWsPJASMY_J0qBTSdP47_yO6GocUwBOmC-5rdxE2Bw'

ActionController::Base.session = {
  :key         => '_welltreat_us_dev',
  :secret      => 'f11cf195514c9f70d208c7860c97b77b2f2fa19cc1b7291d00e26c89530a75077146bc9f0ec4076af5c5fe9b74ec1a9a3de6158a1840712d801103022417cf67',
  :domain      => '.Badok.com'
}