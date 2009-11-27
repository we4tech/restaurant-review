class HomeController < ApplicationController
  layout 'fresh'

  def index
    @title = 'Recently added restaurants!'
    @restaurants = Restaurant.recent.paginate(:page => params[:page])
    @left_modules = [:render_most_lovable_places, :render_recently_added_places]
    @breadcrumbs = []
  end

  def most_loved_places
    offset = params[:page].to_i
    offset = 1 if offset == 0

    @restaurants = WillPaginate::Collection.create(offset, Restaurant::per_page) do |pager|
      result = Restaurant.most_loved(Restaurant::NO_LIMIT, offset)
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Restaurant.count_most_loved
      end
    end

    @title = 'Most loved places!'
    @left_modules = [:render_recently_added_places]
    @breadcrumbs = [['All', root_url]]
    render :action => :index
  end

  def recently_reviewed_places
    offset = params[:page].to_i
    offset = 1 if offset == 0

    @restaurants = WillPaginate::Collection.create(offset, Restaurant::per_page) do |pager|
      result = Restaurant.recently_reviewed(Restaurant::NO_LIMIT, offset)
      pager.replace(result)

      unless pager.total_entries
        # the pager didn't manage to guess the total count, do it manually
        pager.total_entries = Restaurant.count_recently_reviewed
      end
    end

    @title = 'Recently reviewed places!'
    @left_modules = [:render_most_lovable_places]
    @breadcrumbs = [['All', root_url]]
    render :action => :index
  end
end
