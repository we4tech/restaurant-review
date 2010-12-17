module TopicsHelper

  def render_topic_box(p_options)
    topics = Topic.all
    render :partial => 'topics/parts/all_topics', :locals => {:topics => topics}
  end

  def render_topics_selection_box(options = {})
    html = '<select onchange="window.location = this.value" class="topicSelectionBox">'
    Topic.enabled.each do |topic|
      html << "<option value='#{root_url(:subdomain => topic.subdomain)}' #{topic.id == @topic.id ? 'selected="selected"' : ''}>#{topic.label}</option>"
    end
    html << '</select>'
    html
  end

end
