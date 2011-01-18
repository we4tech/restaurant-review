class ProductsController < ApplicationController

  before_filter :login_required, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :detect_restaurant_and_product

  def index
    session[:last_page] = params[:page]
    @products = @restaurant.products.image_attached.all(:limit => Product.per_page)
    @products_count = @restaurant.products.image_attached.count

    if logged_in? && @restaurant.author?(current_user)
      page_index = params[:page].to_i
      page_index = page_index == 0 ? 1 : page_index
      @products_for_admin = @restaurant.products.paginate(:page => page_index)
    end

    render_view('products/index')
  end

  def new
    @product = Product.new
    @product.restaurant_id = @restaurant.id
    
    render_view('products/new')
  end

  def create
    @product = Product.new(params[:product])
    @product.user_id = current_user.id
    @product.topic_id = @topic.id

    if @product.save
      notify :success, "#{site_products_url(@restaurant)}#adminPortion"
    else
      flash[:notice] = 'Failed to create new product'
      render_view('products/new')
    end
  end

  def edit
    if @product && !@product.author?(current_user)
      flash[:notice] = t('errors.authorization')
      redirect_to site_products_url(@restaurant)
    end

    render_view('products/edit')
  end

  def update
    if @product && !@product.author?(current_user)
      flash[:notice] = t('errors.authorization')
      redirect_to site_products_url(@restaurant)
    end

    product_params = params[:product]
    product_params.delete(:user_id)
    product_params.delete(:topic_id)
    product_params.delete(:restaurant_id)

    if @product.update_attributes(product_params)
      notify :success, "#{site_products_url(@restaurant)}#adminPortion"
    else
      flash[:notice] = 'Failed to update your product'
      render_view('products/new')
    end
  end

  def destroy
    if @product && !@product.author?(current_user)
      flash[:notice] = t('errors.authorization')
      redirect_to site_products_url(@restaurant)
    end
    
    if @product.destroy
      notify :success, "#{site_products_url(@restaurant)}#adminPortion"
    else
      notify :failure, "#{site_products_url(@restaurant)}#adminPortion"
    end
  end

  def next
    page_index = params[:page].to_i
    page_index = page_index == 0 ? 1 : page_index
    @products = @restaurant.products.image_attached.paginate(:page => page_index)
    respond_to do |f|
      f.ajax {render :layout => false}
    end
  end

  def show
    render_view('products/show')
  end

  def slide
    @first_image = @product.images.first
    @images = @product.images
    
    render_view('products/slide')
  end

  def reviews
    @site_title = 'Reviews'
    @include_source_object = @product
    @include_source_object_link = site_product_url(@product)
    @attached_options = {
        :attached_model => 'product',
        :attached_id => @product.id
    }
    
    render_view('reviews/index')
  end

  private
    def detect_restaurant_and_product
      @product = nil
      @product = Product.find(params[:id]) if params[:id]

      @restaurant = @restaurant || find_from_post_data ||
                    (@product ? @product.restaurant : nil) ||
                    Restaurant.find(params[:restaurant_id])

    end

    def find_from_post_data
      if params[:product] && params[:product][:restaurant_id]
        Restaurant.find(params[:product][:restaurant_id])
      else
        nil
      end
    end
end
