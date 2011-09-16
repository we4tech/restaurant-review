module CheckinsHelper

  def render_recent_checkins(options = {})
    limit = options[:limit] || 5

    render :partial => 'checkins/parts/recent', :locals => {
        :checkins => @topic.checkins.recent.all(:limit => limit),
        :config => options
    }
  end

  def render_checkin_box
    link = create_checkin_path(url_escape(@topic.name), @restaurant.id)
    html = content_tag 'div', :class => 'checkinBox' do
      content = ''

      if logged_in? && @restaurant.already_checkedin?(current_user)
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
           :locals => {:checkins => @topic.checkins.by_restaurant(@restaurant.id).recent.with_in(hours)})
  end

end
