module UsersHelper

  #
  # Use this to wrap view elements that the user can't access.
  # !! Note: this is an *interface*, not *security* feature !!
  # You need to do all access control at the controller level.
  #
  # Example:
  # <%= if_authorized?(:index,   User)  do link_to('List all users', users_path) end %> |
  # <%= if_authorized?(:edit,    @user) do link_to('Edit this user', edit_user_path) end %> |
  # <%= if_authorized?(:destroy, @user) do link_to 'Destroy', @user, :confirm => 'Are you sure?', :method => :delete end %> 
  #
  #
  def if_authorized?(action, resource, &block)
    if authorized?(action, resource)
      yield action, resource
    end
  end

  #
  # Link to user's page ('users/1')
  #
  # By default, their login is used as link text and link title (tooltip)
  #
  # Takes options
  # * :content_text => 'Content text in place of user.login', escaped with
  #   the standard h() function.
  # * :content_method => :user_instance_method_to_call_for_content_text
  # * :title_method => :user_instance_method_to_call_for_title_attribute
  # * as well as link_to()'s standard options
  #
  # Examples:
  #   link_to_user @user
  #   # => <a href="/users/3" title="barmy">barmy</a>
  #
  #   # if you've added a .name attribute:
  #  content_tag :span, :class => :vcard do
  #    (link_to_user user, :class => 'fn n', :title_method => :login, :content_method => :name) +
  #          ': ' + (content_tag :span, user.email, :class => 'email')
  #   end
  #   # => <span class="vcard"><a href="/users/3" title="barmy" class="fn n">Cyril Fotheringay-Phipps</a>: <span class="email">barmy@blandings.com</span></span>
  #
  #   link_to_user @user, :content_text => 'Your user page'
  #   # => <a href="/users/3" title="barmy" class="nickname">Your user page</a>
  #
  def link_to_user(user, options={ })
    raise "Invalid user" unless user
    options.reverse_merge! :content_method => :login, :title_method => :login, :class => :nickname
    content_text    = options.delete(:content_text)
    content_text    ||= user.send(options.delete(:content_method))
    options[:title] ||= user.send(options.delete(:title_method))
    link_to h(content_text), user_path(user), options
  end

  #
  # Link to login page using remote ip address as link content
  #
  # The :title (and thus, tooltip) is set to the IP address
  #
  # Examples:
  #   link_to_login_with_IP
  #   # => <a href="/login" title="169.69.69.69">169.69.69.69</a>
  #
  #   link_to_login_with_IP :content_text => 'not signed in'
  #   # => <a href="/login" title="169.69.69.69">not signed in</a>
  #
  def link_to_login_with_IP content_text=nil, options={ }
    ip_addr      = request.remote_ip
    content_text ||= ip_addr
    options.reverse_merge! :title => ip_addr
    if tag = options.delete(:tag)
      content_tag tag, h(content_text), options
    else
      link_to h(content_text), login_path, options
    end
  end

  #
  # Link to the current user's page (using link_to_user) or to the login page
  # (using link_to_login_with_IP).
  #
  def link_to_current_user(options={ })
    if current_user
      link_to_user current_user, options
    else
      content_text = options.delete(:content_text) || 'not signed in'
      # kill ignored options from link_to_user
      [:content_method, :title_method].each { |opt| options.delete(opt) }
      link_to_login_with_IP content_text, options
    end
  end

  def render_top_contributors(p_limit = 10)
    if @topic
      users = User.top_contributors(@topic, p_limit)
      render :partial => 'users/parts/top_contributors',
             :locals  => { :users => users, :label => I18n.t('subheader.top_contributors') }
    end
  end

  def render_top_reviewers(p_limit = 10)
    if @topic
      users = User.top_reviewers(@topic, p_limit)
      render :partial => 'users/parts/top_contributors',
             :locals  => { :users => users, :label => I18n.t('subheader.top_reviewers') }
    end
  end

  def load_user_profile(user)
    @left_modules    = [:render_most_lovable_places, :render_recently_reviewed_places]
    @reviews         = user.reviews.by_topic(@topic.id).recent.paginate(:page => params[:rrp], :per_page => 10)
    @review_comments = user.review_comments.by_topic(@topic.id).recent.paginate(:page => params[:rrcp], :per_page => 10)
    @restaurants     = user.restaurants.by_topic(@topic.id).recent.paginate(:page => params[:rp], :per_page => 10)
    @site_title      = "#{(user.name.blank? ? user.login : user.name).camelize}'s profile"
    @breadcrumbs     = [[user.login.camelize, user_url(user)]]
    @title           = 'Profile'
  end

  # Render user status based on his participation
  def render_user_status(user = nil, options = { })
    user           = user || current_user
    checkins_count = user.checkins.by_topic(@topic.id).count
    reviews_count  = user.reviews.by_topic(@topic.id).count
    explores_count = user.restaurants.by_topic(@topic.id).count

    content_tag('div', :class => 'userStatusBox') do
      html = ''

      #html << '<div class="header">Your status</div>' if options[:heading].nil? || options[:heading]

      html << content_tag('div', :class => 'checkins boxItem') do
        "<label>CHECK-INS</label>#{content_tag('div', checkins_count, :class => 'checkinsCount value')}"
      end

      html << content_tag('div', :class => 'reviews boxItem') do
        "<label>REVIEWS</label>#{content_tag('div', reviews_count, :class => 'reviewsCount value')}"
      end


      html << content_tag('div', :class => 'explores boxItem') do
        "<label>EXPLORED</label>#{content_tag('div', explores_count, :class => 'exploresCount value')}"
      end

      html << "<div class='clear'></div>"

      html
    end
  end

  # Render leader board based on user participation
  def render_leader_board(options = { })
    leaders = {
        :eat_outers => Checkin.leaders(@topic),
        :reviewers  => Review.leaders(@topic),
        :explorers  => Restaurant.leaders(@topic)
    }

    render(:partial => 'checkins/parts/leaderboard.html.erb', :locals => { :leaders => leaders, :options => options })
  end

  #
  # Render navigation links for logged in user
  def render_logged_in_user_links
    render_pull_down_menu 'Profile' do
      html = ''

      html << render_avatar
      html << render_fb_share_option
      html << render_admin_links
      html << render_settings_link
      html << render_logout
      html
    end
  end

  #
  # Render user uploaded pictures in a slide
  def render_user_uploaded_pictures(user, options = { })
    images     = user.images.recent.all(:limit => 5)
    thumb      = options.include?(:thumb) ? options[:thumb] : :large
    show_count = options[:show_count]

    if not images.empty?
      container = content_tag('div', :class => 'userImagesContainer') do
        html = ''

        images.each do |image|
          html << %{
            <div class='image'>
              <a href="#{image_url(image)}">
                #{image_tag(image.public_filename(thumb))}
                <div class='countBubble'>#{image.photo_comments.count}</div>
              </a>
            </div>
          }
        end

        html << '<div class="clear"></div>'
        html
      end

      "<div class='userUploadedPictures'>#{container}</div><div class='clear space_10'></div>"
    end
  end

  def render_last_activity(user)
    last_checkin = user.checkins.last
    if last_checkin
      message = content_tag('span', "#{content_tag('strong', 'Last been')} - #{event_or_restaurant_link(last_checkin.any)}")

    else
      last_reviewed = user.reviews.last
      if last_reviewed
        message = content_tag('span', "#{content_tag('strong', 'Last reviewed')} - #{event_or_restaurant_link(last_reviewed.any)}")

      else
        last_explored = user.restaurants.last
        if last_explored
          message = content_tag('span', "#{content_tag('strong', 'Last explored')} - #{restaurant_link(last_explored)}")
        end
      end
    end

    message
  end

  def render_most_explored_tags(user)

  end

  private
    def render_avatar
      content_tag('li') do
        content = content_tag('div', :style => 'float:left;margin-right: 5px;') do
          image_tag(current_user.display_picture, :title => current_user.login, :alt => 'N/A')
        end

        content << content_tag('div', :style => 'float:left') do
          link_to current_user.login, user_long_url(current_user)
        end

        content << content_tag('div', '', :class => 'clear')
        content
      end
    end

    def render_fb_share_option
      if current_user.facebook_session_exists?
        content_tag('li', :class => 'facebook_connect_control') do
          content_tag('span', :class => 'facebook_connect_control') do
            capture_haml do
              form_tag(facebook_account_status_update_url,
                       :id => 'facebook_connect_control_form') do
                content = if current_user.facebook_connect_enabled?
                  tag('input',
                      :id      => 'facebook_share_checkbox',
                      :type    => 'checkbox',
                      :value   => '1',
                      :checked => 'checked',
                      :name    => 'status',
                      :onclick => "$('#facebook_connect_control_form').submit()")
                else
                  tag('input',
                      :id      => 'facebook_share_checkbox',
                      :type    => 'checkbox',
                      :value   => '1',
                      :name    => 'status',
                      :onclick => "$('#facebook_connect_control_form').submit()")
                end
                content << content_tag('label',
                                       t('layout.links.share_on_facebook'),
                                       :for => 'facebook_share_checkbox')
                content
              end
            end
          end
        end
      else
        content_tag('li') do
          content_tag('div',
                      t('layout.links.auto_share_on_facebook'),
                      :class       => "fb-login-button",
                      'data-scope' => FB_CONNECT_PERM)
        end
      end
    end

    def render_admin_links
      if current_user.admin?
        html = content_tag('li', link_to(t('layout.links.admin'), admin_url))
        html << content_tag('li', link_to('Site settings', edit_topic_url(@topic)))
        html
      else
        ''
      end
    end

    def render_settings_link
      content_tag('li', link_to(t('layout.links.edit_user'),
                                edit_user_url(current_user)))
    end

    def render_logout
      if current_user.facebook_session_exists?
        content_tag('li', link_to(t('layout.links.logout'), fb_logout_url))
      else
        content_tag('li', link_to(t('layout.links.logout'), logout_url))
      end
    end
end
