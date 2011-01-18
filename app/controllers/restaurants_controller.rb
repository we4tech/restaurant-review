class RestaurantsController < ApplicationController

  before_filter :login_required, :except => [:show, :premium]
  before_filter :log_new_feature_visiting_status
  before_filter :set_premium_session, :only => [:premium]
  before_filter :unset_premium_session, :except => [:premium]
   
  caches_action :show, :cache_path => Proc.new {|c| 
    c.cache_path(c, [:id])
  }, :if => Proc.new {|c| !c.send(:mobile?)}
   	
  def new
    if topic_imposed_limit_allows?
      @restaurant = Restaurant.new
      @form_fields = @topic.form_attribute.fields
      @allow_image_upload = @topic.form_attribute.allow_image_upload
      @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
      @edit_mode = true
    else
      flash[:notice] = 'You already have a profile with us, you can update!'
      redirect_to edit_restaurant_url(current_user.restaurants.by_topic(@topic.id).first.id)
    end
  end

  def create
    @allow_image_upload = @topic.form_attribute.allow_image_upload
    @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
    @restaurant = Restaurant.new(params[:restaurant])
    @restaurant.user = current_user
    @restaurant.topic_id = @topic.id

    if @restaurant.save
      flash[:notice] = 'Successfully saved new restaurant!'
      if current_user.share_on_facebook?
        redirect_to facebook_publish_url('new_restaurant', @restaurant.id, :next_to => edit_restaurant_url(@restaurant))
      else
        redirect_to edit_restaurant_url(@restaurant)
      end
    else
      @form_fields = @topic.form_attribute.fields
      @edit_mode = true
      flash[:notice] = "Failed to store new #{@topic.name.humanize} information!"
      render :action => :new
    end
  end

  def show
    @restaurant = Restaurant.find(params[:id].to_i)

    if redirected_to_long_url_if_its_not?
      return true
    end

    @cached = true if params[:jsonp].nil? || params[:jsonp] != 'false'
    @site_title = "#{@restaurant.name} #{@restaurant.address.blank? ? '' : "@ #{@restaurant.address}"} "
    @form_fields = @topic.form_attribute.fields
    @allow_image_upload = @topic.form_attribute.allow_image_upload
    @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload

    if @restaurant.reviews.count > 0
      user_given_rating = @restaurant.rating_out_of(Restaurant::RATING_LIMIT)
      @meta_description = "Read unbiased reviews of " +
                          "#{@restaurant.reviews.count} people, who loved and rated " +
                          "'#{@restaurant.name}' in average " +
                          "#{user_given_rating > 0 ? user_given_rating.round(1) : 0}" +
                          " out of #{Restaurant::RATING_LIMIT.to_f} "
    else
      @meta_description = "Read unbiased reviews of '#{@restaurant.name}'"
    end
    @meta_keywords = "#{@restaurant.tags.collect(&:name).join(', ')} " +
                     "#{@restaurant.address}, Bangladeshi, restaurant, review," +
                     " community".gsub('"', '\'')

    load_module_preferences
    @view_context = ViewContext::CONTEXT_RESTAURANT_DETAILS
    @left_modules = [
        :render_tagcloud,
        :render_search,
        :render_most_lovable_places,
        :render_recently_added_places,
        :render_topic_box]
        
    respond_to do |format|
      format.html { render }
	    format.mobile { render :text => 'Disabled'}
      format.xml {
      	options = {}
      	options[:only] = params[:fields] if params[:fields]
      	render :xml => @restaurant.to_xml(options)
      }
    end
  end

  def redirected_to_long_url_if_its_not?
    if params[:topic_name].nil?
      redirect_to restaurant_long_url(@restaurant)
    end
  end

  def premium
    @restaurant = Restaurant.find(params[:id].to_i)
    set_premium_session
    @premium = true

    if @restaurant.premium?
      @premium_template = @restaurant.selected_premium_template
      @context = :home
      respond_to do |format|
        format.html { pt_render_template 'layout' }
        format.mobile { render :text => 'Sorry, We don\'t have support for mobile view.'}
      end
    else
      flash[:notice] = 'this is not a premium restaurant!'
      redirect_to root_url
    end
  end

  def coming_soon
    @restaurant = Restaurant.find(params[:id].to_i)

    if @restaurant.premium?
      @premium_template = @restaurant.selected_premium_template
      @premium_service_subscriber = PremiumServiceSubscriber.new
      @context = :home
      pt_render_template 'coming_soon'
    else
      flash[:notice] = 'this is not a premium restaurant!'
      redirect_to root_url
    end
  end

  def edit
    restaurant = Restaurant.find(params[:id].to_i)

    if restaurant.author?(current_user)
      @form_fields = @topic.form_attribute.fields
      @allow_image_upload = @topic.form_attribute.allow_image_upload
      @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
      @edit_mode = true
      @restaurant = restaurant
    else
      flash[:notice] = "You are not authorized to edit this entry!"
      redirect_to root_url
    end
  end

  def update
    restaurant = Restaurant.find(params[:id].to_i)
    user_id = current_user.id

    # Don't change original author if super admin is performing this operation
    if current_user.admin?
      user_id = restaurant.user_id
    end

    if restaurant.author?(current_user)
      attributes = params[:restaurant].merge(
          :user_id => user_id, :topic_id => @topic.id)
      attributes[:long_array] ||= []
      attributes[:short_array] ||= []
      attributes[:extra_notification_recipients] ||= []

      restaurant.apply_filters(params[:filters], attributes)

      if restaurant.update_attributes(attributes)
        if (params[:fb_share].nil? || params[:fb_share] == 'true') &&
            current_user.share_on_facebook?
          flash[:notice] = 'Saved and shared your updates!'
          return_to = params[:return_to] || edit_restaurant_url(restaurant)
          redirect_to facebook_publish_url('updated_restaurant', restaurant.id, :next_to => return_to)
        else
          flash[:notice] = 'Saved your updates!'
          redirect_to params[:return_to] || edit_restaurant_url(restaurant)
        end
      else
        @form_fields = @topic.form_attribute.fields
        flash[:notice] = 'Failed to store your updated!'
        @restaurant = restaurant
        @edit_mode = true
        render :action => :edit
      end
    else
      flash[:notice] = "You are not authorized to edit this entry!"
      redirect_to root_url
    end
  end

  def destroy
    restaurant = Restaurant.find(params[:id].to_i)
    if restaurant.author?(current_user)
      if restaurant.destroy
        flash[:notice] = "You have removed an entry - #{restaurant.name}"
      else
        flash[:notice] = "Failed to remove this entry - #{restaurant.name}"
      end
    else
      flash[:notice] = "You are not authorized to delete this entry!"
    end

    redirect_to root_url
  end

  def update_record
    redirect_to edit_restaurant_url(:id => current_user.restaurants.by_topic(@topic.id).first.id)
  end

  def edit_tags
    @restaurant = Restaurant.find(params[:id].to_i)
    @tags = @topic.tags
    session[:last_url] = request.env['HTTP_REFERER']
  end

  #
  # TODO: It has hard coded binding with long_array
  #
  def save_tags
    @restaurant = Restaurant.find(params[:id].to_i)

    tag_ids = (params[:tag_ids] || []).collect(&:to_i).compact
    if tag_ids.empty?
      flash[:notice] = 'No tags were selected!'
      redirect_to edit_tags_restaurant_path(@restaurant)
    else
      @restaurant.tag_mappings.destroy_all
      update_tag_mappings(tag_ids, @restaurant)

      flash[:success] = 'Stored tag maps!'
      redirect_to session[:last_url] || restaurant_long_url(@restaurant)
    end

  end

  def featured
    restaurant = Restaurant.find(params[:id].to_i)
    restaurant.update_attribute(:featured, !restaurant.featured?)
    notify :success, :back
  end

  def test_email_template
    args = []
    params[:args].each do |arg|
      case arg
        when 'user'
          args << User.first
        when 'restaurant'
          args << Restaurant.first
        when 'review'
          args << Review.first
        when 'review_comment'
          args << ReviewComment.first
      end
    end
    mail = UserMailer.send("create_#{params[:m]}", args.length > 1 ? args : args.first)
    render :inline => "#{mail.body}"
  end

  def add_recipient
    @restaurant = Restaurant.find(params[:id].to_i)
  end

  private
    def update_tag_mappings(tag_ids, restaurant)
      tags = Tag.find(tag_ids)
      tags.each do |tag|
        TagMapping.create(
            :topic => @topic,
            :restaurant => restaurant,
            :tag => tag,
            :user => restaurant.user)
      end

      restaurant.update_attribute(:long_array, tags.collect(&:name))
    end

    def topic_imposed_limit_allows?
      form_attribute = @topic.form_attribute
      form_attribute && form_attribute.allows_more_entry?(@topic, current_user)
    end

end
