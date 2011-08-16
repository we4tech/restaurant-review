module CheckinsHelper

  def render_recent_checkins(options = {})
    limit = options[:limit] || 5

    render :partial => 'checkins/parts/recent', :locals => {
        :checkins => @topic.checkins.recent.all(:limit => limit),
        :config => options
    }
  end
end
