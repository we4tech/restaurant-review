module FacebookConnectHelper

  FACEBOOK_CONNECT_COOKIE_PREFIX = "fbs_"
  FACEBOOK_CONNECT_SESSION_ID = :fb_connect_user

  def check_facebook_connect_session

    if !fb_connect_session # not exists
      # Try to load facebook connect cookies
      # Create new facebook session and store on session
      fb_session = build_fb_session

      # If cookies are found
      if fb_session && fb_session.user

        # Create new facebook session and store on session
        fb_uid = fb_session.user.uid

        # Ensure associated user is already in database
        # otherwise create new user and assign on session

        if !User.exists?(:facebook_uid => fb_uid)
          user = User.register_by_facebook_account(fb_session, fb_uid)
          user.log_it!(request.remote_addr)
        else
          user = User.update_facebook_session(fb_uid, fb_session)
          user.log_it!(request.env["HTTP_X_FORWARDED_FOR"] || request.remote_addr)
        end

        self.current_user = User.find_by_facebook_uid(fb_uid)
        create_fb_connect_session(fb_session)
        flash[:notice] = 'You are logged in through your facebook account'
      end
    end
  end

  private

    def fb_connect_session
      session[FACEBOOK_CONNECT_SESSION_ID]
    end

    def build_fb_session
      fb_cookie = cookies["#{FACEBOOK_CONNECT_COOKIE_PREFIX}#{@topic.fb_connect_key.blank? ? Facebooker.api_key : @topic.fb_connect_key}"]
      parsed = {}

      if fb_cookie && !fb_cookie.blank?
        parsed = parse_fb_cookie(fb_cookie)

      elsif params[:fskey] && params[:fuid]
        parsed = {
            'session_key' => params[:fskey],
            'uid' => params[:fuid],
            'expires' => params[:fexpires],
            'secret' => params[:fsecret],
            'access_token' => params[:fat]
            }
      end

      if parsed && !parsed.empty?
        @facebook_session = new_facebook_session
        @facebook_session.secure_with!(
            parsed['session_key'],
            parsed['uid'],
            parsed['expires'],
            parsed['secret'])
        @facebook_session.auth_token = parsed['access_token']
        @facebook_session
      else
        nil
      end
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
