require 'digest/sha1'

class User < ActiveRecord::Base

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  validates_presence_of :login
  validates_length_of :login,    :within => 3..40
  validates_uniqueness_of :login
  validates_format_of :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of :name,     :maximum => 100

  validates_presence_of :email
  validates_length_of :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of :email
  validates_format_of :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message


  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :facebook_sid, :facebook_uid, :remember_token, :remember_token_expires_at

  has_many :restaurants
  has_many :images
  has_many :reviews
  has_many :review_comments
  has_many :stuff_events
  has_many :subscribed_restaurants, :source => :restaurant, :through => :stuff_events
  has_many :user_logs
  has_one :related_image
  has_one :image, :through => :related_image

  FACEBOOK_CONNECT_ENABLED = 1
  FACEBOOK_CONNECT_DISABLED = 0


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def self.top_contributors(p_limit = 10)
    User.find(
        :all,
        :select => 'DISTINCT users.*',
        :joins => :restaurants,
        :group => 'restaurants.id',
        :order => 'count(restaurants.id) DESC',
        :limit => p_limit
    )
  end

  def self.top_reviewers(p_limit = 10)
    User.find(
        :all,
        :select => 'DISTINCT users.*',
        :joins => :reviews,
        :group => 'reviews.id',
        :order => 'count(reviews.id) DESC',
        :limit => p_limit
    )
  end

  def share_on_facebook?
    reloaded_me = self.reload
    return reloaded_me.facebook_connect_enabled == User::FACEBOOK_CONNECT_ENABLED &&
        reloaded_me.facebook_sid.to_i > 0 &&
        reloaded_me.facebook_uid.to_i > 0
  end

  def facebook_session_exists?
    reloaded_me = self.reload
    reloaded_me.facebook_sid.to_i > 0 && reloaded_me.facebook_uid.to_i > 0
  end

  def generate_remember_token
    write_attribute :remember_token, encrypt("#{Time.now.to_f * rand}")
    write_attribute :remember_token_expires_at, (Time.now + 1.hour)

    self.update_attributes(
        :remember_token => encrypt("#{Time.now.to_f * rand}"),
        :remember_token_expires_at => (Time.now + 1.hour)
    )
  end

  def count_updates_since_i_last_visited(p_topic)
    user_log = self.user_logs.by_topic(p_topic.id).first
    if user_log
      count = StuffEvent.count(:conditions => [
          'restaurant_id IN (?) AND user_id != ? AND created_at > ?',
          subscribed_restaurants.collect{|r| r.id}, self.id, user_log.updated_at
      ])
      count
    else
      0
    end
  end
  
  protected
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end


end
