module UrlOverrideHelper

  def restaurant_long_url(p_options)
    topic = @topic
    topic = Topic.default if topic.nil?

    options = p_options.merge(:topic_name => topic.name.pluralize)
    restaurant_long_route_url(options)
  end
end
