module HomeHelper

  def render_search(p_options)
    render :partial => 'home/parts/search',
           :locals => {:title => p_options['label'].humanize.pluralize} 
  end
end
