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
    render_pull_down_menu('Topics') do
      Topic.enabled.collect do |topic|
        content_tag('li', content_tag('a', topic.label, :href => topic_public_host(topic)))
      end.join('')
    end
  end

  def render_pull_down_menu(name, options = {}, &block)
    menu_id = options[:link_id] || "nav_pm_#{rand}".gsub(/\./, '')
    sub_menu_id = options[:menu_id] || menu_id + '_sub_menu'

    html = content_tag('a', name, :class => 'navPullDownMenu', :id => menu_id)

    html << content_tag('ul', :class => 'navPullDownSubMenu',
                        :id => sub_menu_id,
                        :style => 'display:none') do
      block.call()
    end

    html << %{
      <script type='text/javascript'>
        $('##{menu_id}').wtsPullDown($('##{sub_menu_id}'));
      </script>
    }
  end

end
