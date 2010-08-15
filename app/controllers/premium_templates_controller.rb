class PremiumTemplatesController < ApplicationController

  before_filter :login_required
  
  def index
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @premium_templates = @restaurant.premium_templates
  end

  def new
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)

    if_permits?(@restaurant) do
      @premium_template = PremiumTemplate.new(:restaurant_id => @restaurant.id)
      @templates = load_templates
    end
  end

  def create
    @restaurant = Restaurant.find(params[:premium_template][:restaurant_id].to_i)

    if_permits?(@restaurant) do
      @premium_template = PremiumTemplate.new(params[:premium_template])
      @premium_template.user = current_user

      if @premium_template.save
        @restaurant.update_attribute(:premium, true)
        notify :success, restaurant_premium_templates_path(@restaurant)
      else
        @templates = load_templates
        notify :failure, :new
      end
    end
  end

  def destroy
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @premium_template = PremiumTemplate.find(params[:id].to_i)

    if_permits?(@restaurant) do
      if @premium_template.destroy
        notify :success, restaurant_premium_templates_path
      else
        notify :failure, restaurant_premium_template_path
      end
    end
  end

  def edit
    @restaurant = Restaurant.find(params[:restaurant_id].to_i)
    @premium_template = PremiumTemplate.find(params[:id].to_i)
    @templates = load_templates
  end

  def update
    @premium_template = PremiumTemplate.find(params[:id].to_i)
    @restaurant = @premium_template.restaurant

    if_permits?(@restaurant) do
      if @premium_template.update_attributes(params[:premium_template])
        @restaurant.update_attribute(:premium, true)
        notify :success, restaurant_premium_templates_path(@restaurant)
      else
        @templates = load_templates
        notify :failure, :edit
      end
    end
  end

  def design
    @premium_template = PremiumTemplate.find(params[:id].to_i)
    @restaurant = @premium_template.restaurant

    if_permits?(@restaurant) do
      @templates = load_templates
      @edit_mode = true
      @context = :design
      render :layout => false, :template => "templates/#{@premium_template.template}/layout"
    end
  end

  private

    def load_templates
      Dir.glob(File.join(RAILS_ROOT, 'app', 'views', 'templates', '*')).collect{|f|
        f.gsub(/#{RAILS_ROOT}\/app\/views\/templates\//, '')
      }
    end

end
