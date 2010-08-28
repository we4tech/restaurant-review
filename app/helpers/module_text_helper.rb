module ModuleTextHelper

  DEFAULT_KEY = 'rich_text'

  #
  # Render edit mode for rich text box
  def edit_rich_text(options = {})
    render :partial => 'rich_text/modules/edit_rich_text',
           :object => template_element(options, DEFAULT_KEY)
  end

  #
  # Render rich text content
  def rich_text(options = {})
    data = template_element(options, DEFAULT_KEY).data || [{}]
    if !data.empty?
      data.first['text']
    else
      'No Text was set'
    end
  end
end
