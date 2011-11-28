module ApplicationHelper

  def detect_premium_site_or_topic_or_forward_to_default_one
    if @premium_template = PremiumTemplate.match_host(request.host)
      @restaurant = @premium_template.restaurant
      @topic = @restaurant.topic
      store_last_premium_site_host
      set_premium_session
      @premium = true

      if request.path == '/'
        @context = :home
        pt_render_view
      end
    else
      detect_topic_or_forward_to_default_one
    end
  end

  def detect_topic_or_forward_to_default_one

    # Match topic by topic hosts
    if match_topic_by_host.nil?

      # Match topic by subdomain
      if match_topic_by_subdomain.nil?

        # Match topic by specified special parameter __topic_id
        if match_topic_by_topic_id.nil?

          # Load default topic if exists
          if default_topic_selected.nil?
            # Throw error message if none of them matches.
            flash[:notice] = "Invalid domain name - '#{request.host}'"
            redirect_to root_url(:subdomain => false)
            return
          end
        end
      end
    end

    if @topic
      if logged_in? && @topic.form_attribute.record_insert_type == FormAttribute::SINGLE_RECORD
        @record_already_added = current_user.restaurants.by_topic(@topic.id).length > 0
      end
    end

  end

  def default_topic_selected
    @topic = Topic.default
    if @topic
      path_prefix = (request.path || '')
      path_prefix = path_prefix[1..path_prefix.length]
      full_path = "#{root_url(:subdomain => @topic.subdomain)}"
      full_path.insert(full_path.index('?'), CGI.unescape(path_prefix))
      redirect_to full_path
    end

    @topic
  end

  def match_topic_by_topic_id
    if @topic.nil? && params[:__topic_id]
      @topic = Topic.find(params[:__topic_id])
    end

    @topic
  end

  def match_topic_by_subdomain
    if @topic.nil?
      topic_hint = (request.subdomains || []).join("_")
      if !topic_hint.blank? && topic_hint.downcase != 'www'
        @topic = Topic.of(topic_hint)
      end
    end

    @topic
  end

  def match_topic_by_host
    @topic = Topic.match_host(request.host)
    if @topic
      @subdomain_routing_stop = true

      # Determine whether this is a subdomain and user profile page
      handle_subdomain_content_mapping
    end

    @topic
  end

  # Handle different type of subdomain page based on future features
  # Topic::SUBDOMAIN_CONTENT_TYPE
  # NOTE: subdomain routing will serve different home page instead of home#frontpage
  def handle_subdomain_content_mapping
    if @topic.user_subdomain?
      domain_name = (request.subdomains || []).join('')

      if !domain_name.blank? && !domain_name.match(/ajax|asset|www/) && (request.path || '').length < 2
        @user = User.by_domain_name(domain_name)
        if @user
          determine_rotatable_background_image
          cache_fragment(cache_path(self)) do
            @cache = true
            page_context [:list_page, :profile_page]
            load_user_profile(@user)
            render :template => 'users/show_v2'
          end
        else
          render :text => 'User doesn\'t exist'
        end
      end
    end
  end

  def load_module_preferences
    @modules_pref = {}
    (@topic.modules || []).each do |module_pref|
      @modules_pref[module_pref['name'].to_sym] = module_pref
    end
  end

  def load_right_modules
    load_module_preferences
    @left_modules = [
        :render_tagcloud,
        :render_search,
        :render_most_lovable_places,
        :render_recently_reviewed_places,
        :render_topic_box]
  end

  def render_view(partial_template, options = {})
    if @restaurant && premium?
      render_restaurant_based_template(partial_template, options)
    else
      @content_template = partial_template
      if options[:inner]
        render :template => 'layouts/fresh_inner_layout', :locals => (options[:locals] || {})
      else
        render :partial => partial_template, :layout => 'fresh'
      end
    end
  end

  def render_restaurant_based_template(partial_template, options = {})
    @premium_template = @restaurant.selected_premium_template
    @context = :inner_page

    if !params[:d] && @premium_template
      @inner_page = partial_template

      if params[:layout].nil?
        if !File.exists?(File.join(RAILS_ROOT, 'app', 'views', "templates/#{@premium_template.template}/layout.#{params[:format]}.erb"))
          params[:format] = :html
        end

        render :layout => false, :template => "templates/#{@premium_template.template}/layout"
      else
        render :layout => false, :template => "templates/#{@premium_template.template}/#{params[:layout]}"
      end
    else
      @content_template = partial_template
      render :template => 'layouts/fresh_inner_layout', :locals => options[:locals]
    end
  end

  def detect_name(object)
    if object.respond_to?(:name)
      object.name
    elsif object.respond_to?(:title)
      object.title
    else
      object.type.name.humanize
    end
  end

  def flash_message_exists?
    flash_message_any
  end

  def flash_message_any
    flash[:notice] || flash[:error]
  end

  def embedded_view?
    'true' == params[:embed_view]
  end

  # Avail current request view rendering context
  def page_context(context = nil)
    @context ||= []

    if context
      if context.is_a?(Array)
        context.each { |c| @context << c }
      else
        @context << context
      end
    end

    @context
  end

  def page_context_as_classes
    if page_context.is_a?(String)
      page_context (page_context || '').split(',')
    end

    contexts = page_context
    contexts = [contexts] if not contexts.is_a?(Array)
    contexts.collect { |pc| "context_#{pc}" }.join(' ')
  end

  # Add module renderer helper for the specified position
  def page_module(position, module_renderer_helper, options = {})
    @page_modules ||= {}
    @page_modules[position] ||= []
    @page_modules[position] << [module_renderer_helper, options]
  end

  # Render all modules which are associated with the specific position
  def render_page_modules(position)
    return if @page_modules.nil?

    modules = @page_modules[position]
    html = ''

    if modules && !modules.empty?
      modules.each do |module_pref|
        html << __send__(module_pref.first.to_sym, module_pref.last)
      end
    end

    html
  end

  def prepare_breadcrumbs
    @breadcrumbs = [['All', root_url]]

    if params[:filters]
      add_breadcrumb_for(:tag)
      add_breadcrumb_for(:user)
    end

    @breadcrumbs
  end

  def add_breadcrumb_for(key)
    filter_key = "#{key.to_s}_id"
    if !(_id = params[:filters][filter_key]).blank?
      _ids = _id.split('|').compact

      if !_ids.empty?
        instance_variable_set :"@#{key}", key.to_s.classify.constantize.find(_ids.first)

        if key == :tag
          @breadcrumbs << [instance_variable_get(:"@#{key}").name_with_group, section_url(instance_variable_get(:"@#{key}"), true)]
        else
          @breadcrumbs << [instance_variable_get(:"@#{key}").login, user_long_url(instance_variable_get(:"@#{key}"))]
        end
      end
    end
  end

  def render_breadcrumbs
    if @breadcrumbs && !@breadcrumbs.empty?
      content_tag('h1', :class => 'breadcrumbs') do
        html = ''
        @breadcrumbs.each_with_index do |link, index|
          html << link_to(link.first, link.last,
                          :class => 'crumb')
          html << '&raquo; '
        end
        html << content_tag('div', @title, :class => 'crumb')

        html
      end
    end
  end

  def redirectable?
    request.headers["Referer"]
  end

  def log_last_visiting_time
    if current_user
      @user_log = current_user.user_logs.by_topic(@topic.id).first
      if @user_log
        @user_log.update_attribute(:updated_at, Time.now)
      else
        @user_log = UserLog.create(:user_id => current_user.id, :topic_id => @topic.id)
      end
    end
  end

  def log_new_feature_visiting_status
    @dont_show_new_features = []
    host_parts = request.host.split(/\./)
    host = host_parts[(host_parts.length - 2)..host_parts.length].join('.')

    if defined?(NEW_FEATURES)
      cookie = cookies[:new_feature]

      if cookie.nil?
        cookies[:new_feature] = {
            :domain => host,
            :value => '',
            :expires => 1.year.from_now
        }
      else
        key = "#{params[:controller]}_#{params[:action]}"
        NEW_FEATURES.each do |feature_name, feature|
          if !cookie.include?(feature_name.to_s) && feature[:unless_visited_on].include?(key)
            cookies[:new_feature] = {
                :domain => host,
                :value => "#{cookie}|#{feature_name.to_s}",
                :expires => 1.year.from_now
            }
            @dont_show_new_features << feature_name
          elsif cookie.include?(feature_name.to_s)
            @dont_show_new_features << feature_name
          end
        end
      end
    end
  end

  def remove_html_entities(p_str)
    (p_str || '').gsub(/<[\/\w\d\s="\/\/\.:'@#;\-]+>/, '')
  end

  #
  # Generate flash message based on given types (success or failure)
  # and/or redirect to *redirect* url
  def notify(type, redirect, options = {})
    case type
      when :success
        flash[:success] = options[:success_message] || 'Successfully completed!'
        redirect_to redirect

      when :failure
        flash[:notice] = options[:failure_message] || 'Failed to complete!'
        if redirect.is_a?(Symbol) && redirect != :back
          render :action => redirect
        else
          redirect_to redirect
        end
    end
  end

  #
  # Check whether the current user is authorized or not
  def authorize
    if !current_user || !current_user.admin?
      flash[:notice] = 'You are not authorized to access this url.'
      redirect_to root_url
    end
  end
end
