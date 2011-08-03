class AdminController < ApplicationController

  before_filter :login_required
  before_filter :log_new_feature_visiting_status
  
  def index
    page_context :list_page
  end

end
