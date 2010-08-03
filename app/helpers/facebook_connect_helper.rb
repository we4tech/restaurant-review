module FacebookConnectHelper

  FACEBOOK_CONNECT_COOKIE_PREFIX = "fbs_"
  FACEBOOK_CONNECT_SESSION_ID = :fb_connect_user

  def check_facebook_connect_session

    logger.debug(':: Check facebook connect session')
    if !fb_connect_session # not exists
      logger.debug('No FB connect session exists')

      # Try to load facebook connect cookies
      fb_cookie = cookies["#{FACEBOOK_CONNECT_COOKIE_PREFIX}#{Facebooker.api_key}"]
      logger.debug("Fb connect cookie - #{fb_cookie.inspect}")

      # If cookies are found
      if fb_cookie && !fb_cookie.blank?

        # Create new facebook session and store on session
        fb_session = build_fb_session(fb_cookie)
        fb_uid = fb_session.user.uid

        # Ensure associated user is already in database
        # otherwise create new user and assign on session

        if !User.exists?(:facebook_uid => fb_uid)
          logger.debug("No user exists, create new - #{fb_uid}")
          User.register_by_facebook_account(fb_session, fb_uid)
        else
          logger.debug("Update existing user - #{fb_uid}")
          User.update_facebook_session(fb_uid, fb_session)
        end

        self.current_user = User.find_by_facebook_uid(fb_uid)
        create_fb_connect_session(fb_session)
        flash[:notice] = 'You are logged in through your facebook account'
      end
    else
      logger.debug('FB connect session found')
    end
  end

  private

    def fb_connect_session
      session[FACEBOOK_CONNECT_SESSION_ID]
    end

    def build_fb_session(fb_cookie)
      parsed = parse_fb_cookie(fb_cookie)

      @facebook_session = new_facebook_session
      @facebook_session.secure_with!(
          parsed['session_key'],
          parsed['uid'],
          parsed['expires'],
          parsed['secret'])
      @facebook_session.auth_token = parsed['access_token']
      @facebook_session
    end

    def create_fb_connect_session(fb_session)
      session[FACEBOOK_CONNECT_SESSION_ID] = fb_session
    end

    def parse_fb_cookie(fb_cookie)
      map = {}
      fb_cookie = fb_cookie.gsub(/"/, '')
      fb_cookie.split('&').collect do |part|
        parts = part.split('=');
        map[parts.first] = parts.last
      end
      map['expires'] = Time.at(map['expires'].to_i)
      map
    end
end
