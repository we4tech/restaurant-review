class ProductsController < ApplicationController

  before_filter :login_required
  before_filter :detect_restaurant_and_product

  def index
    session[:last_page] = params[:page]
    @products = @restaurant.products.image_attached.all(:limit => Product.per_page)
    @products_count = @restaurant.products.image_attached.count

    if @restaurant.author?(current_user)
      @products_for_admin = @restaurant.products.paginate(:page => params[:page])
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
    render_view('products/edit')
  end

  def update
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
    if @product.destroy
      notify :success, "#{site_products_url(@restaurant)}#adminPortion"
    else
      notify :failure, "#{site_products_url(@restaurant)}#adminPortion"
    end
  end

  def next
    @products = @restaurant.products.image_attached.paginate(:page => params[:page])
    respond_to do |f|
      f.ajax {render :layout => false}
    end
  end

  private
    def detect_restaurant_and_product
      @product = nil
      @product = Product.find(params[:id]) if params[:id]

      @restaurant = @restaurant || find_from_post_data ||
                    (@product ? @product.restaurant : nil) ||
                    Restaurant.find(params[:restaurant_id])

      if @product && !@product.author?(current_user)
        flash[:notice] = t('errors.authorization')
        redirect_to site_products_url(@restaurant)
      end
    end

    def find_from_post_data
      if params[:product] && params[:product][:restaurant_id]
        Restaurant.find(params[:product][:restaurant_id])
      else
        nil
      end
    end
end
