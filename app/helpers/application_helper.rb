# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def detect_topic_or_forward_to_default_one
    topic_hint = (request.subdomains || []).join("_")
    if topic_hint.empty? || topic_hint == 'www'
      topic = Topic.default
      path_prefix = (request.path || '')
      path_prefix = path_prefix[1..path_prefix.length]
      redirect_to "#{root_url(:subdomain => topic.subdomain)}#{path_prefix}"
      return
    else
      @topic = Topic.find_by_name(topic_hint)
    end

    if !@topic
      flash[:notice] = "Invalid domain name - '#{topic_hint}'"
      redirect_to root_url(:subdomain => false)
    else
      if logged_in? && @topic.form_attribute.record_insert_type == FormAttribute::SINGLE_RECORD
        @record_already_added = current_user.restaurants.by_topic(@topic.id).length > 0
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
        :render_recently_added_places,
        :render_topic_box]
  end

  def render_view(partial_template)
    @premium_template = @restaurant.selected_premium_template
    @context = :inner_page

    if !params[:d] && @premium_template
      @inner_page = partial_template

      if !File.exists?(File.join(RAILS_ROOT, 'app', 'views', "templates/#{@premium_template.template}/layout.#{params[:format]}.erb"))
        params[:format] = :html  
      end

      render :layout => false, :template => "templates/#{@premium_template.template}/layout"
    else
      load_right_modules
      @content_template = partial_template
      render :template => 'layouts/fresh_inner_layout'
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
end
