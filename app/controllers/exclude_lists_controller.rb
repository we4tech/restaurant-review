class ExcludeListsController < ApplicationController

  before_filter :login_required

  def create

    if current_user.admin?
      exclude_list_item = LeaderBoardExcludeList.new(params[:leader_board_exclude_list])
      if exclude_list_item.save
        flash[:success] = 'We\'ve just excluded that guy!'
      end
    else
      flash[:notice] = 'You are not authorized to perform this action'
    end

    redirect_to root_url
  end
end
