module PagesHelper

  def page_exists?(url)
    Page.exists?(:url => url)
  end
end
