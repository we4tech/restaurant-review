class UsersController < ApplicationController

  before_filter :login_required, :only => [
      :edit, :update_facebook_connect_status,
      :update_facebook_connect_account_status,
      :suspend, :unsuspend, :destroy, :purge
  ]
  before_filter :log_new_feature_visiting_status

  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  before_filter :find_user, :only => [:suspend, :unsuspend, :destroy, :purge]
  

  # render new.rhtml
  def new
    @user = User.new
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    @user.register! if @user && @user.valid?
    success = @user && @user.valid?
    if success && @user.errors.empty?
      @user.activate!
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render :action => 'new'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a user with that activation code <br/> check your email? Or maybe you've already activated <br/> try signing in."
      redirect_back_or_default('/')
    end
  end

  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  def destroy
    @user.delete!
    redirect_to users_path
  end

  def purge
    @user.destroy
    redirect_to users_path
  end
  
  def edit
    find_user
    authorized?
  end

  def authorized?
    if @user.id != current_user.id
      flash[:notice] = 'You are not authorized to access this page!'
      redirect_to root_url
      false
    else
      true
    end
  end

  def update
    find_user
    if authorized?
      if @user.update_attributes(params[:user])
        notify :success, root_url
      else
        notify :failure, :edit
      end
    end
  end

  def facebook_connect
    raise params.inspect
  end

  def update_facebook_connect_status
    user = current_user.reload
    user.facebook_uid = params[:uid] if params[:uid]
    user.facebook_sid = params[:sid] if params[:sid]
    status = user.save(false)

    render :text => "Update status - #{status.inspect}"
  end

  def update_facebook_connect_account_status
    status = params[:status].to_i
    status = User::FACEBOOK_CONNECT_ENABLED if status > User::FACEBOOK_CONNECT_ENABLED
    current_user.update_attribute(:facebook_connect_enabled, status)

    flash[:notice] = "#{status == User::FACEBOOK_CONNECT_ENABLED ? 'enabled' : 'disabled'} your facebook sharing."
    redirect_to :back
  end

  def reset_password
  end

  def process_reset_password
    email = params[:email]
    user = User.find_by_email(email)
    if user
      user.generate_remember_token
      UserMailer.deliver_reset_password(user)
      flash[:notice] = "Please check your '#{email}' email inbox."
      redirect_to login_url
    else
      flash[:notice] = "No account associated with '#{email}', please try again."
      redirect_to reset_password_url
    end
  end

  def change_password
    @token = params[:token].to_s
    @user = User.find_by_remember_token(@token)

    if @user.nil?
      flash[:notice] = 'Invalid password change request.'
      redirect_to login_url
    elsif Time.now > @user.remember_token_expires_at
      flash[:notice] = 'You password change request has been expired.'
      redirect_to login_url
    end
  end

  def save_new_password
    @token = params[:token]
    @user = User.find_by_remember_token(@token)

    if @user && Time.now <= @user.remember_token_expires_at
      password = params[:password]
      confirm_password = params[:confirm_password]

      if !(password.blank? && confirm_password.blank?) && password == confirm_password
        saved = @user.update_attributes(
            :password => password,
            :password_confirmation => confirm_password,
            :remember_token => nil,
            :remember_token_expires_at => nil
        )

        if saved
          flash[:notice] = 'Great!, it\'s done. now you can login :)_)'
          redirect_to login_url
        else
          flash[:notice] = 'Invalid password, please write 6 or more chars long password'
          render :action => :change_password
        end
      else
        flash[:notice] = 'Invalid password, password does not match.'
        render :action => :change_password
      end
    else
      flash[:notice] = 'Your password reset request has expired, please try again.'
      redirect_to login_url
    end
  end

  def show
    @user = User.find(params[:id].to_i)
    @left_modules = [:render_most_lovable_places, :render_recently_added_places]
    @reviews = @user.reviews.by_topic(@topic.id).recent.paginate(:page => params[:rrp], :per_page => 10)
    @review_comments = @user.review_comments.by_topic(@topic.id).recent.paginate(:page => params[:rrcp], :per_page => 10)
    @restaurants = @user.restaurants.by_topic(@topic.id).recent.paginate(:page => params[:rp], :per_page => 10)
    @site_title = "#{@user.login.camelize}'s profile"
  end

protected
  def find_user
    @user = User.find(params[:id])
  end
end
