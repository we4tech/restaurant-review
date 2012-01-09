Factory.sequence :event_name do |n|
  "event name #{n}"
end

Factory.sequence :event_description do |n|
  "event description #{n}"
end

Factory.define :topic_event do |u|
  u.name  { Factory.next :event_name }
  u.description { Factory.next :event_description }
  u.event_type TopicEvent::EVENT_TYPES_MAP.values.sample
  u.start_at Time.now - 1.day
  u.end_at Time.now + 1.day
  u.address 'dhaka, bangladesh'
end

Factory.define :upcoming_event, :parent => :topic_event do |u|
  u.start_at Time.now + 2.day
  u.end_at Time.now + 4.days
end

Factory.define :recent_event, :parent => :topic_event do |u|
  u.start_at Time.now - 4.days
  u.end_at Time.now - 1.day
end

Factory.define :ongoing_event, :parent => :topic_event do |u|
  u.start_at Time.now - 1.day
  u.end_at Time.now + 3.days
end