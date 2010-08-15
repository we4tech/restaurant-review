module ModuleTextHelper

  DEFAULT_KEY = 'rich_text'

  #
  # Render edit mode for rich text box
  def edit_rich_text(options = {})
    key = options[:key] || DEFAULT_KEY
    render :partial => 'rich_text/modules/edit_rich_text', 
           :object => @premium_template.find_or_create_element(key)
  end

  #
  # Render rich text content
  def rich_text(options = {})
    key = options[:key] || DEFAULT_KEY
    data = @premium_template.find_or_create_element(key).data || [{}]
    if !data.empty?
      data.first['text']
    else
      'No Text was set'
    end
  end
end
