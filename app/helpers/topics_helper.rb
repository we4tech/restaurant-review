module TopicsHelper

  def render_topic_box(p_options)
    topics = Topic.enabled
    render :partial => 'topics/parts/all_topics', :locals => {:topics => topics}
  end

  #
  # Determine public host based on default host name and other attributes
  def topic_public_host(topic)
    root_url(topic.public_host_config)
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
