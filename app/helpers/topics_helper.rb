module TopicsHelper

  def render_topic_box(p_options)
    topics = Topic.enabled
    render :partial => 'topics/parts/all_topics', :locals => {:topics => topics}
  end

  #
  # Determine public host based on default host name and other attributes
  def topic_public_host(topic)
    topic_host = root_url(:host => 'welltreat.us', :subdomain => topic.subdomain, :l => topic.locale(:en))
    if topic.default_host
      topic_host = root_url(:host => topic.default_host, :subdomain => 'www', :l => topic.locale(:en))
    end

    topic_host
  end

  def render_topics_selection_box(options = {})
    html = '<select onchange="window.location = this.value" class="topicSelectionBox">'
    Topic.enabled.each do |topic|
      html << "<option value='#{topic_public_host(topic)}' #{topic.id == @topic.id ? 'selected="selected"' : ''}>#{topic.label}</option>"
    end
    html << '</select>'
    html
  end

end
