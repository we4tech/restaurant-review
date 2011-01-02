module StuffEventsHelper

  def render_activities_link
    count = 0
    if current_user && @topic
      count = current_user.count_updates_since_i_last_visited(@topic)
    end

    link_to t('nav.updates', :count => count),
            updates_url,
            :rev => '#activities_submenu',
            :class => "#{count > 0 ? 'link_has_update submenu' : 'submenu'}",
            :id => 'activities_link'
  end
end
