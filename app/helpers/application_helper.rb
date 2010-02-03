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
end
