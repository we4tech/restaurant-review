module ModuleNewsHelper

  KEY_RECENT_NEWS = 'recent_news'
  DEFAULT_MAX_NEWS_COUNT = 5

  #
  # Render recent news
  # +Parameters+
  # - max     - maximum number of news
  # - offset  - paginate recent news
  #
  def edit_recent_news(options = {})
    options = process_arguments(options)

    offset = options[:offset]
    max = options[:max]
    type_id = options[:type_id]
    key = options[:key]

    messages = @restaurant.messages.all(
        :conditions => {:type_id => type_id}, :offset => offset, :limit => max)

    editor = render :partial => 'messages/modules/edit_recent_news',
                    :locals => {
                        :config => @premium_template.find_or_create_element(key),
                        :messages => messages}
    viewable = recent_news(options)

    "#{editor}<div class='space_5 break'></div>#{viewable}"
  end

  #
  # Render recent news
  def recent_news(options = {})
    options = process_arguments(options)

    offset = options[:offset]
    max = options[:max]
    type_id = options[:type_id]
    key = options[:key]

    # Override default configuration if user has added through
    # template edit panel
    element = @premium_template.find_or_create_element(key)
    config = element.data.first

    if config && config['max'].to_i > 0
      max = config['max']
    end

    # Retrieve all messages
    messages = @restaurant.messages.all(
        :conditions => {:type_id => type_id}, :limit => max, :offset => offset)

    render :partial => 'messages/modules/recent_news',
           :locals => {:messages => messages}
  end

  private
  def process_arguments(options)
    arguments = {}
    options.stringify_keys!

    arguments[:offset] = options['offset'].to_i
    arguments[:max] = options['max'].to_i
    arguments[:max] = DEFAULT_MAX_NEWS_COUNT if arguments[:max] == 0
    arguments[:type_id] = options['type'] || Message::TYPE_NEWS
    arguments[:key] = options['key'] || KEY_RECENT_NEWS

    arguments
  end
end
