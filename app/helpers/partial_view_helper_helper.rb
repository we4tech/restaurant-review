module PartialViewHelperHelper

  def render_partially_item(restaurant_or_event)
    if restaurant_or_event
      partial_file_name = nil
      map_variable = {}

      case restaurant_or_event
        when Restaurant
          partial_file_name = 'restaurants/parts/restaurant'
          map_variable[:restaurant] = restaurant_or_event
        when TopicEvent
          partial_file_name = 'topic_events/parts/event'
          map_variable[:topic_event] = restaurant_or_event
      end

      render :partial => partial_file_name,
             :locals => map_variable
    else
      ''
    end
  end
end
