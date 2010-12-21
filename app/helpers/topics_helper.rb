module TopicsHelper

  def render_topic_box(p_options)
    topics = Topic.all
    render :partial => 'topics/parts/all_topics', :locals => {:topics => topics}
  end

  def render_topics_selection_box(options = {})
    html = '<select onchange="window.location = this.value" class="topicSelectionBox">'
    Topic.enabled.each do |topic|
      topic_host = root_url(:host => 'welltreat.us', :subdomain => topic.subdomain, :l => topic.locale(:en))
      if topic.default_host
        topic_host = root_url(:host => topic.default_host, :l => topic.locale(:en))
      end
      html << "<option value='#{topic_host}' #{topic.id == @topic.id ? 'selected="selected"' : ''}>#{topic.label}</option>"
    end
    html << '</select>'
    html
  end

end
