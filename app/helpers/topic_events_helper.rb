module TopicEventsHelper

  # Generate friendly event date
  # ie. Today, Tomorrow at 3:20,
  def render_friendly_event_schedule(event)
    starting_days_count = (event.start_at - Time.now) / 1.day
    message = ''

    # Only none expired events
    if event.end_at > Time.now

      # Upcoming events
      if starting_days_count.to_i > 0
        message = "On #{event.start_at.strftime('%A, %B %d %Y at %I:%M %p')} #{pluralize(starting_days_count.round.abs, 'day')} left"

      # Happening today
      elsif starting_days_count.round == 0
        message = "Today #{event.start_at.strftime('%I:%M %p')}"

      # Already started
      elsif starting_days_count < 0
        message = "Happening now, started #{pluralize(starting_days_count.round.abs, 'day')} ago"

      # Upcoming but less than 1 day left
      else
        message = "#{distance_of_time_in_words(Time.now, event.end_at)} left"
      end

    # For expired events
    else
      message = "Closed #{distance_of_time_in_words(Time.now, event.end_at)} ago"
    end

    html = "<acronym title='Started: #{event.start_at.strftime('%A, %B %d %Y')}, Ended: #{event.end_at.strftime('%A, %B %d %Y')}'>"
    html << message
    html << '</acronym>'
  end

  def render_upcoming_events(options = {})
    events = TopicEvent.exciting_events(@topic, {:limit => 5}.merge(options))
    render :partial => 'topic_events/parts/upcoming.html.haml',
           :locals => {:events => events, :options => options}
  end
end
