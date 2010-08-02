module StuffEventsHelper

  def render_activities_link
    count = ""
    if current_user
      count = current_user.count_updates_since_i_last_visited(@topic)
    end

    link_to t('nav.updates', :count => count),
            updates_url,
            :class => "#{count > 0 ? 'link_has_update' : ''}",
            :id => 'activities_link'
  end
end
