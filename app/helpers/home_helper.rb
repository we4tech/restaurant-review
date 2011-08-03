module HomeHelper

  def render_search(p_options)
    render :partial => 'search/modules/search',
           :locals => {:title => p_options['label'].humanize} 
  end

  #
  # Render the list of sections with the selected item from each
  # If nothing is selected from the section the TOP Most loved
  # item will be automatically selected.
  # Otherwise editor selected items will be showed.
  #
  # The display picture will be determined by the specific image tag "Section view"
  # This function is called with *page_key* which is intended for preparing data
  # according to the page type. So we can utilize the same function for having sub
  # section with their sub section data.
  def render_section_heads_with_selected_item(page_key = nil)
    render :partial => 'home/parts/section_heads', :locals => {:sections => Tag.sections}
  end
end
