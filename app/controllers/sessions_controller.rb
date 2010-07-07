# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  before_filter :log_new_feature_visiting_status
  
  # render new.rhtml
  def new
  end

  def create
    logout_keeping_session!
    user = User.authenticate(params[:login], params[:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      new_cookie_flag = (params[:remember_me] == "1")
      handle_remember_cookie! new_cookie_flag

      if user.image
        flash[:notice] = "Logged in successfully"
        redirect_back_or_default(updates_url)
      else
        flash[:notice] = "Logged in successfully, please upload your display picture (avatar)!"
        redirect_to edit_user_url(user)
      end

      if !current_user.user_logs.by_topic(@topic.id).first
        log_last_visiting_time
      end
    else
      note_failed_signin
      @login       = params[:login]
      @remember_me = params[:remember_me]
      render :action => 'new'
    end
  end

  def login_as
    if current_user && current_user.admin? && params[:user]
      self.current_user = User.find_by_login(params[:user])
      handle_remember_cookie!(false)
      flash[:notice] = "You have logged in as - #{params[:user]}"
    else
      flash[:notice] = "You are not authorized to preform this action."
    end

    redirect_to root_url
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    cookies.delete("#{FacebookConnectHelper::FACEBOOK_CONNECT_COOKIE_PREFIX}#{Facebooker.api_key}")
    redirect_back_or_default('/')
  end

  def fb_destroy
    session[FacebookConnectHelper::FACEBOOK_CONNECT_SESSION_ID] = nil    
    cookies.delete("#{FacebookConnectHelper::FACEBOOK_CONNECT_COOKIE_PREFIX}#{Facebooker.api_key}")
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
end
