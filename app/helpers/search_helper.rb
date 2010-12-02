require 'timeout'

module SearchHelper

  METERS_PER_KILOMETER = 1000

  def build_search_query(map, values = [])
    query = ""
    map.each do |fields, value|
      parts = []
      if value.is_a?(Array) 
      	parts = value
      elsif value.is_a?(Hash)
        parts = value.values
      else 
        value.split(/\s/)
      end
      
      query << "@(#{fields.split('|').join(',')}) \"#{parts.join(' ')}\"/#{parts.length - 1 > 0 ? parts.length - 1 : 1} "
    end

    query
  end

  def perform_search(models, query, options = {})

    sort_by = '@weight DESC'

    # Apply specific model
    if models && !models.empty?
      options[:class_names] = models.collect(&:to_s)
    end

    # Apply topic based filter
    options[:filters] = (options[:filters] || {}).merge(:topic_id => @topic.id)

    # Define page index
    page_index = options[:page] || params[:page]

    # If location is given prepare meter based options
    if options.include?(:location)
      geo_params = process_location(options[:location])

      if geo_params.include?(:location)
        options[:location] = geo_params[:location]
      end

      if geo_params.include?(:sort_by)
        sort_by = geo_params[:sort_by]
      end

      if geo_params.include?(:filters)
        options[:filters] = options[:filters].merge(geo_params[:filters])
      end
    end

    # Start performing search
    begin
      search = Ultrasphinx::Search.new(
          {:query => query,
           :sort_mode => 'extended',
           :weights => {
               'name' => 3.0,
               'short_array' => 3.0,
               'long_array' => 2.5,
               'address' => 3.0
           },
           :per_page => Restaurant::per_page,
           :sort_by => sort_by,
           :page => page_index.nil? ? 1 : page_index.to_i}.merge(options))
      search.run
      search
    rescue => $e
      logger.error($e)
      if $e.is_a?(Errno::ECONNREFUSED)
        UserMailer::deliver_server_status_notification('DOWN Ultrasphinx', %{
Dear server admin,
could you please turn on sphinx server? we can't reach it here!

Error messages -
#{$e.to_s}})        
      end
      WillPaginate::Collection.new(1, 10, 0)
    end
  end

  private
    def process_location(location)
      lat = (location[:lat].to_f / 180.0) * Math::PI
      long = (location[:long].to_f / 180.0) * Math::PI 
      meter = location[:meter].to_f

      {:location => {:lat => lat, :long => long},
       :filters => {'distance' => 0.0..meter},
       :sort_by => 'distance'}
    end
  
end
