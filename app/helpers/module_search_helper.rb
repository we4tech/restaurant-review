module ModuleSearchHelper

  def edit_search(options = {})
    search(options)
  end

  def search(options = {})
    render :partial => 'search/modules/search'
  end
end
