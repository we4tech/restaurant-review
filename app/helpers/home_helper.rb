module HomeHelper

  def render_search(p_options)
    render :partial => 'search/modules/search',
           :locals => {:title => p_options['label'].humanize} 
  end
end
