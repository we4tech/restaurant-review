require 'timeout'

module SearchHelper

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
    if models && !models.empty?
      options[:class_names] = models.collect(&:to_s)
    end

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
           :sort_by => '@weight DESC',
           :page => params[:page].nil? ? 1 : params[:page].to_i}.merge(options))
      search.run
      search
    rescue => $e
      logger.error($e)
      UserMailer::deliver_server_status_notification('DOWN Ultrasphinx', %{
Dear server admin,
could you please turn on sphinx server? we can't reach it here!

Error messages -
#{$e.to_s}})
      WillPaginate::Collection.new(1, 10, 0)
    end
  end
  
end
