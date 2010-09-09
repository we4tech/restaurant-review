class PagesController < ApplicationController

  before_filter :login_required, :except => [:show]

  def show
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @premium_template = @restaurant.selected_premium_template
    @page = @restaurant.pages.by_url(params[:page_name]).first

    if @page
      @site_title = @page.title
    else
      @site_title = 'Page not available'
    end
    
    @view_context = ViewContext::CONTEXT_RESTAURANT_DETAILS
    render_view('pages/embed_show')
  end

  def new
    @restaurant = Restaurant.find(params[:restaurant_id])
    @page = @restaurant.pages.by_url(params[:page_name]).first

    if @page
      flash[:notice] = 'You already have an existing page.'
      redirect_to edit_restaurant_page_path(@restaurant, @page)
    else
      @page = Page.new
      render_view('pages/new')
    end
  end

  def create
    @restaurant = Restaurant.find(params[:page][:restaurant_id])
    @page = Page.new(params[:page])
    @page.user = current_user

    if @page.save
      notify :success, premium_restaurant_path(@restaurant.id)
    else
      notify :failure, :new
    end
  end

  def edit
    @page = Page.find(params[:id].to_i)
    @restaurant = @page.restaurant

    render_view('pages/edit')
  end

  def update
    @page = Page.find(params[:id].to_i)
    @restaurant = @page.restaurant

    if @page.update_attributes(params[:page])
      notify :success, readable_page_path(@restaurant.id, @page.url)
    else
      notify :failure, :edit 
    end
  end
end
