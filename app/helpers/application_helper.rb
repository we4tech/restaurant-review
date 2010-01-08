# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def detect_topic_or_forward_to_default_one
    topic_hint = request.subdomains || []
    if topic_hint.empty?
      @topic = Topic.default
    else
      @topic = Topic.find_by_name(topic_hint)
    end

    if !@topic
      flash[:notice] = "Invalid domain name - '#{topic_hint}'"
      redirect_to root_url(:subdomain => false)
    end
  end
end
