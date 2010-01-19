# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def detect_topic_or_forward_to_default_one
    topic_hint = (request.subdomains || []).join("_")
    if topic_hint.empty? || topic_hint == 'www'
      topic = Topic.default
      redirect_to root_url(:subdomain => topic.name)
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
end
