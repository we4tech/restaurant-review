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
  attr_accessible :login, :email, :name, :password,
                  :password_confirmation, :facebook_sid,
                  :facebook_uid, :remember_token,
                  :remember_token_expires_at

  has_many :restaurants
  has_many :images
  has_many :reviews
  has_many :review_comments
  has_many :stuff_events
  has_many :subscribed_restaurants, :source => :restaurant, :through => :stuff_events
  has_many :user_logs
  has_many :messages
  has_many :resource_importers
  has_one :related_image
  has_one :image, :through => :related_image
  has_many :topic_events

  FACEBOOK_CONNECT_ENABLED = 1
  FACEBOOK_CONNECT_DISABLED = 0

  before_save :update_domain_name


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

  def login
    if read_attribute(:login)
      read_attribute(:login)
    else
      self.name.parameterize.to_s
    end
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  #
  # Determine user display picture either from his uploaded one or from his facebook profile
  # (if he has registered through facebook account)
  # Otherwise return our default display picture
  def display_picture
    if self.image
      self.image.public_filename(:very_small)
    elsif facebook_uid.to_i > 0
      FacebookGraphApi::display_picture(facebook_uid, 'square')
    else
      '/images/fresh/user.png'
    end
  end

  #
  # Strip all symbols, ie - _, -, @, . etc..
  # Only characters are allowed.
  def convert_to_subdomain
    self.login.gsub(/\-/, '')
  end

  #
  # Detect whether this account was auto created and thus set fake email id.
  # we set fake email with "fake" prefix so it is quite easy to figure out
  # the fake emails. thus system can force user to set the real email address.
  def fake_email?
    self.email.match(/^fake@/)
  end

  #
  # Return the state of whether this user has reviewed the specific restaurant or not
  # Parameters
  #   - restaurant  - restaurant object
  #   - options     - optional parameters are in hash map
  # Returns
  #   - boolean true or false
  def reviewed?(restaurant, options = {})
    self.reviews.of_restaurant(restaurant, options).first
  end

  #
  # Find user by the given sub domain name, ie hasan.khadok.com
  def self.by_domain_name(domain_name)
    domain_name = domain_name.parameterize.to_s.gsub(/\-/, '')
    self::find_by_domain_name(domain_name)
  end

  #
  # Retrieve the top contributors from the participation on specific topic
  # parameters -
  #   - p_topic   - Topic object
  #   - p_limit   - Number of rows to be returned
  # returns -
  #   - array of users
  def self.top_contributors(p_topic, p_limit = 10)
    User.find(
        :all,
        :select => 'DISTINCT users.*',
        :joins => :restaurants,
        :group => 'restaurants.id',
        :order => 'count(restaurants.id) DESC',
        :conditions => ['restaurants.topic_id = ?', p_topic.id],
        :limit => p_limit
    )
  end

  #
  # Retrieve the top reviewers based on their participation on specific topic
  # parameters -
  #   - p_topic     - Topic object
  #   - p_limit     - Number of rows to be returned
  # returns -
  #   - array of users
  def self.top_reviewers(p_topic, p_limit = 10)
    User.find(
        :all,
        :select => 'DISTINCT users.*',
        :joins => :reviews,
        :group => 'reviews.id',
        :order => 'count(reviews.id) DESC',
        :conditions => ['reviews.topic_id = ?', p_topic.id],
        :limit => p_limit
    )
  end

  #
  # Register user by his facebook account,
  # Retrieve facebook user profile information through graph api call
  def self.register_by_facebook_account(fb_session, fb_uid)
    api = FacebookGraphApi.new(fb_session.auth_token, fb_uid)
    user_attributes = api.find_user(fb_uid)
    email = user_attributes['email'] || 'FAKE'
    name = user_attributes['name'] || ''

    if !email.blank? && !name.blank?
      existing_user = User.find_by_email(email)
      existing_user = User.find_by_facebook_uid(fb_uid) if existing_user.nil?

      if existing_user
        existing_user.facebook_uid = fb_uid
        existing_user.facebook_sid = fb_session.auth_token
        existing_user.facebook_connect_enabled = true
        existing_user.save(false)

        existing_user.update_attribute(:state, 'active')
      else
        attributes = {
            :login => find_or_build_unique_user_name(name),
            :name => name,
            :email => find_or_build_unique_fake_email(email),
            :facebook_uid => fb_uid,
            :facebook_sid => fb_session.session_key,
            :activated_at => Time.now,
            :state => 'active',
            :facebook_connect_enabled => true
        }

        user = User.new(attributes)
        user.save(false)

        user.update_attribute(:state, 'activate')
      end
    else
      # Do something else let's log him out from facebook
      raise 'Durrr! you are one of those unlucky person for whom we haven\'t fixed this bug!
            please let me know that i told you this crap!' + " data - #{user_attributes.inspect}" 
    end
  end

  #
  # Update user with active facebook session
  def self.update_facebook_session(fb_uid, fb_session)
    existing_user = User.find_by_facebook_uid(fb_uid)
    existing_user.facebook_sid = fb_session.auth_token
    existing_user.save(false)
  end

  private
    def update_domain_name
      self.domain_name = convert_to_subdomain
    end

    def self.find_or_build_unique_user_name (name)
      name = CGI.escape(name.parameterize.to_s)
      if self.unique?(:login, name)
        name
      else
        "#{name}-#{Time.now.to_i.to_s[6..10].to_i}"
      end
    end

    def self.find_or_build_unique_fake_email(email)
      if email.downcase != 'fake' && self.unique?(:email, email)
        email
      elsif email.downcase == 'fake'
        "#{email}@#{Time.now.to_i.to_s[6..10].to_i}.com"
      else
        email
      end
    end

  public

  def self.unique?(field, value)
    !User.send("find_by_#{field}", value)
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
          'topic_id = ? AND restaurant_id IN (?) AND user_id != ? AND created_at > ?',
          p_topic.id, subscribed_restaurants.collect(&:id).uniq, self.id, user_log.updated_at
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
