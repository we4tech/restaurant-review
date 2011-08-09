module StuffEventsHelper
  #
  # Retrieve recent activities if there is logged in user retrieve only user activities.
  def recent_activities
    user_log = nil
    subscribed_restaurants = nil

    filters = params[:filters]
    tag_ids = []
    user_ids = []
    restaurant_ids = []
    excluded_user_ids = []

    if filters && filters[:tag_id]
      tag_ids = filters[:tag_id].split('|').compact
    end

    if filters && filters[:restaurant_id]
      restaurant_ids = filters[:restaurant_id].split('|').compact
    end

    if filters && filters[:excluded_user_id]
      excluded_user_ids = filters[:excluded_user_id].split('|').compact
    end

    if filters && filters[:user_id]
      user_ids = filters[:user_id].split('|').compact
    end

    if current_user
      subscribed_restaurants = current_user.subscribed_restaurants.
          by_topic(@topic.id).all(:group => 'restaurants.id')
      user_log = current_user.user_logs.by_topic(@topic.id).first
      subscribed_restaurants.each{|r| restaurant_ids << r.id}

      if !user_ids.include?(current_user.id.to_s)
        excluded_user_ids << current_user.id
      end
    end

    stuff_events = StuffEvent.
      by_topic(@topic.id).
      by_tags(tag_ids).
      by_restaurants(restaurant_ids).
      by_users(user_ids).
      exclude_users(excluded_user_ids).recent.paginate(:page => params[:page])

    {
      :user_log => user_log,
      :stuff_events => stuff_events,
      :subscribed_restaurants => subscribed_restaurants
    }
  end

  # -- View related helpers
  def render_activity_icon(event)
    prefix = '/images/icons/dryicons/'
    case event.event_type
      when StuffEvent::TYPE_CHECKIN
        prefix + 'map.png'
      when StuffEvent::TYPE_RELATED_IMAGE
        prefix + 'add.png'
      when StuffEvent::TYPE_CONTRIBUTED_IMAGE
        prefix + 'add.png'
      when StuffEvent::TYPE_REVIEW
        prefix + 'comment.png'
      when StuffEvent::TYPE_REVIEW_COMMENT
        prefix + 'comments.png'
      when StuffEvent::TYPE_RESTAURANT
        prefix + 'document.png'
      when StuffEvent::TYPE_RESTAURANT_UPDATE
        prefix + 'info.png'
      when StuffEvent::TYPE_PHOTO_COMMENT
        prefix + 'comments.png'
    end
  end

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

  #
  # Render pull down menu for user activities
  def render_user_activities_pull_down_menu
    count = current_user.count_updates_since_i_last_visited(@topic)
    render_pull_down_menu("Notification(#{count})", :link_id => 'activities_link', :menu_id => 'activities_submenu') do
      '<li>Loading...</li>'
    end
  end

  # Return a story text from the specified *StuffEvent* instance
  def render_activity_story(event)
    message = "<div class='storyTitle'>#{link_to event.user.login, user_long_url(event.user)}&nbsp;"
    case event.event_type
      when StuffEvent::TYPE_RELATED_IMAGE
        prepare_story_for_image_upload(event, message)
      when StuffEvent::TYPE_CONTRIBUTED_IMAGE
        prepare_story_for_image_contribution(event, message)
      when StuffEvent::TYPE_RESTAURANT
        prepare_story_for_restaurant_add(event, message)
      when StuffEvent::TYPE_RESTAURANT_UPDATE
        prepare_story_for_restaurant_update(event, message)
      when StuffEvent::TYPE_REVIEW
        prepare_story_for_review_add(event, message)
      when StuffEvent::TYPE_REVIEW_COMMENT
        prepare_story_for_review_comment(event, message)
      when StuffEvent::TYPE_CHECKIN
        prepare_story_for_checkin(event, message)
      when StuffEvent::TYPE_PHOTO_COMMENT
        prepare_story_for_photo_comment(event, message)
      else
        message << '</div>'
        
    end
    message
  end

  #
  # Group events by the date of occurrence
  def group_by_date(events)
    grouped_events = ActiveSupport::OrderedHash.new

    events.each do |event|
      if event.created_at.today?
        grouped_events[:today] ||= []
        grouped_events[:today] << event

      elsif yesterday?(event.created_at)
        grouped_events[:yesterday] ||= []
        grouped_events[:yesterday] << event

      else
        key = event.created_at.strftime('%d %b %Y')
        grouped_events[key] ||= []
        grouped_events[key] << event
      end
    end

    grouped_events
  end

  def render_news_feed(options = {})
    topic = options.delete(:topic) || @topic
    page_index = params[:page].to_i > 0 ? params[:page].to_i : 1
    per_page = options.delete(:limit) || StuffEvent.per_page
    tag_ids = []
    user_ids = []

    # If filter option is specified look up for tag ids
    if options[:filters]
      tag_ids = single_or_multiple_value options[:filters][:tag_id]
      user_ids = single_or_multiple_value options[:filters][:user_id]
    end

    stuff_events = StuffEvent.by_topic(topic.id).by_tags(tag_ids).by_users(user_ids).recent.
      paginate(:page => page_index, :per_page => per_page)

    more_link = tag_ids.empty? && user_ids.empty? ? updates_path : updates_path(
      'filters[tag_id]' => tag_ids.join('|'), 'filters[user_id]' => user_ids.join('|'))

    render :partial => 'stuff_events/parts/news_feed',
           :locals => {:config => options,
                       :stuff_events => stuff_events, :more_link => more_link}
  end

  private
    def single_or_multiple_value(value)
      if value.is_a?(Array)
        value
      else
        [value].compact
      end
    end

    def yesterday?(date)
      now = Time.now.at_beginning_of_day - 1.day
      [date.day, date.month, date.year] == [now.day, now.month, now.year]
    end

    def prepare_story_for_photo_comment(event, message)
      c_small_image = event.image.thumbnails.of_thumbnail('c_small').first

      message << "Commented on #{link_to event.restaurant.name, restaurant_long_url(event.restaurant)}'s picture</div>"
      message << "<div class='storyDetails' style='display:none'>"
      message << "<div class='storyImage' onclick='window.location=\"#{image_path(event.image)}\";' style='width:#{c_small_image.width}px'><div class='storyCommentsCount'>#{event.image.photo_comments.count}</div>#{link_to image_tag(event.image.c_small_public_filename), image_path(event.image.id)}</div>"

      if !event.image.caption.blank?
        message << "<div class='storyReview'>#{event.photo_comment.content}</div>"
      end

      message << "</div>"
    end

    def prepare_story_for_checkin(event, message)
      time_diff_in_mins = (Time.now - event.created_at).to_i / 1.minute # Minutes

      # If event age is with in 10 mins
      if time_diff_in_mins < 10
        message << 'just arrived'

      # If event age is with in 60 mins
      elsif time_diff_in_mins < 60
        # If not been away
        # Check whether any other place already been checked in by this user
        last_checkin = event.user.checkins.last
        if last_checkin.ref_id == event.ref_id
          message << 'still at'

        # If been away
        else
          message << 'was at'
        end

      # If event age is with in 2 hours
      else
        message << 'was at'
      end

      map_link = nil
      if event.restaurant
        full_map_path(:rid => event.any.id)
      elsif event.topic_event
        full_map_path(:eid => event.any.id)
      end

      message << " #{event_or_restaurant_link(event.any)} at #{link_to event.any.address, map_link}</div>"
    end

    def prepare_story_for_review_comment(event, message)
      message << "commented on #{user_link(event.review.user, :same_user_check => event.user)}'s review on #{restaurant_link(event.restaurant)}.</div>"
      if !event.review_comment.content.blank?
        message << "<div class='storyDetails' style='display:none'>"
        message << "<div class='storyReview'>#{truncate(strip_tags(event.review_comment.content), 200)}</div>"
        message << "</div>"
      end
    end

    def prepare_story_for_review_add(event, message)
      message << (event.review.loved? ? 'loved ' : (event.review.wanna_go? ? 'wants to go ' : 'disliked '))

      if !event.review.comment.blank?
        if event.review.wanna_go?
          message << ' and left note on '
        else
          message << ' and commented on '
        end
      else
        if event.review.wanna_go?
          message << 'to '
        end
      end

      message << "#{link_to truncate(event.review.any.name, 30), "#{event_or_restaurant_url(event.review.any)}#review-#{event.review.id}"}.</div>"

      if !event.review.comment.blank?
        message << "<div class='storyDetails' style='display:none'>"
        message << "<div class='storyReview'>#{truncate(strip_tags(event.review.comment), 200)}</div>"
        message << "</div>"
      end
    end

    def prepare_story_for_restaurant_add(event, message)
      message << "added new #{@topic.name} #{link_to event.restaurant.name, restaurant_long_url(event.restaurant)}.</div>"
    end

    def prepare_story_for_restaurant_update(event, message)
      message << "updated #{link_to event.restaurant.name, restaurant_long_url(event.restaurant)}'s information.</div>"
    end

    def prepare_story_for_image_contribution(event, message)
      c_small_image = event.image.thumbnails.of_thumbnail('c_small').first

      message << "added new image to the #{link_to event.restaurant.name, restaurant_long_url(event.restaurant)}.</div>"
      message << "<div class='storyDetails' style='display:none'>"
      message << "<div class='storyImage' onclick='window.location=\"#{image_path(event.image)}\";' style='width:#{c_small_image.width}px'><div class='storyCommentsCount'>#{event.image.photo_comments.count}</div>#{link_to image_tag(event.image.c_small_public_filename), image_path(event.image.id)}"

      if !event.image.caption.blank?
        message << "<div class='storyCaption'>#{event.image.caption}</div>"
      end

      message << "</div></div>"
    end

    def prepare_story_for_image_upload(event, message)
      c_small_image = event.image.thumbnails.of_thumbnail('c_small').first

      message << "added new image to the '#{link_to event.restaurant.name, restaurant_long_url(event.restaurant)}'</div>"
      message << "<div class='storyDetails' style='display:none'>"
      message << "<div class='storyImage' onclick='window.location=\"#{image_path(event.image)}\";' style='width:#{c_small_image.width}px'><div class='storyCommentsCount'>#{event.image.photo_comments.count}</div>#{link_to image_tag(event.image.c_small_public_filename), image_path(event.image.id)}"

      if !event.image.caption.blank?
        message << "<div class='storyCaption'>#{event.image.caption}</div>"
      end

      message << "</div></div>"
    end
end
