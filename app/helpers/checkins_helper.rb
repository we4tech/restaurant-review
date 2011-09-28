module CheckinsHelper

  def render_recent_checkins(options = {})
    limit = options[:limit] || 5

    render :partial => 'checkins/parts/recent', :locals => {
        :checkins => @topic.checkins.recent.all(:limit => limit),
        :config => options
    }
  end

  def render_checkin_box
    topic_name = url_escape(@topic.name)
    topic_name = 'topic-event' if any_ref.is_a?(TopicEvent)

    link = create_checkin_path(topic_name, any_ref.id)
    html = content_tag 'div', :class => 'checkinBox' do
      content = ''

      if logged_in? && any_ref.already_checkedin?(current_user)
        content << content_tag('button', 'You have checked in!', :class => 'gray_button')
      else
        content << content_tag('button', 'Check In Here',
                               :onclick => "window.location='#{link}'")
      end

      content
    end

    html
  end

  def render_recently_checkedin_users(hours = 5.hours)
    render(:partial => 'checkins/parts/who_else_here',
           :locals => {:checkins => @topic.checkins.by_restaurant(any_ref.id).recent.with_in(hours)})
  end

end
