# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.12' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem "chronic"
  config.gem "rubyist-aasm", :version => '2.1.1', :lib => 'aasm'
  config.gem "will_paginate", :version => '2.3.11'
  config.gem 'super_exception_notifier', :lib => "exception_notification"
  config.gem "mail_style"
  config.gem "i18n", :version => '0.4.2'
  config.gem "RedCloth"
  config.gem 'rest-client'
  config.gem 'haml'
  config.gem 'sass'
  config.gem 'coffee-script'
  config.gem 'uglifier'
  config.gem 'yui-compressor', :lib => 'yui/compressor'
  config.gem 'jammit'
  #config.gem 'rack-cache'


  #config.gem 'jammit', :version => '0.5.1'

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  config.active_record.observers = [
      :user_observer, :review_comment_observer,
      :review_observer, :restaurant_observer,
      :checkin_observer, :related_image_observer,
      :contributed_image_observer, :restaurant_sweeper,
      :topic_event_sweeper, :review_sweeper,
      :image_sweeper, :image_cache_sweeper, :photo_comment_observer]

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Dhaka'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  config.i18n.load_path += Dir[Rails.root.join('_generated', '*', 'locales', '*.yml')]
  config.i18n.default_locale = :en

end

require File.join(RAILS_ROOT, 'lib', 'rails_ext')