class RestaurantsController < ApplicationController

  before_filter :login_required, :except => [:show]
  before_filter :log_new_feature_visiting_status

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
    @site_title = "#{@restaurant.name} #{@restaurant.address.blank? ? '' : "@ #{@restaurant.address}"} "
    @form_fields = @topic.form_attribute.fields
    @allow_image_upload = @topic.form_attribute.allow_image_upload
    @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
    @meta_description = "Read unbiased and friendly user reviews of " +
                        "#{@restaurant.rating_out_of(Restaurant::RATING_LIMIT)}" + 
                        " out #{Restaurant::RATING_LIMIT} rated "
                        "'#{@restaurant.name}' from #{@restaurant.address}. " +
                        " #{@restaurant.reviews.loved.count} out of " +
                        "#{@restaurant.reviews.count} people loved this restaurant!"
    @meta_keywords = "#{@restaurant.tags.collect(&:name).join(', ')} " +
                     "#{@restaurant.address}, Bangladeshi, restaurant, review," +
                     " community".gsub('"', '\'')

    load_module_preferences
    @left_modules = [
        :render_tagcloud,
        :render_search,
        :render_most_lovable_places,
        :render_recently_added_places,
        :render_topic_box]
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

      if restaurant.update_attributes(attributes)
        if current_user.share_on_facebook?
          flash[:notice] = 'Saved and shared your updates!'
          redirect_to facebook_publish_url('updated_restaurant', restaurant.id, :next_to => edit_restaurant_url(restaurant))
        else
          flash[:notice] = 'Saved your updates!'
          redirect_to edit_restaurant_url(restaurant)
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

  def recommend
    @tag_ids = params[:tag_ids] || []

    if @tag_ids.empty?
      @restaurants = []
    else
      @tag_ids = @tag_ids.collect(&:to_i)
      @restaurants = load_paginated_restaurants
    end

    @breadcrumbs = [['Home', root_url]]
    @title = 'Recommend restaurants!'

    # pending module - :render_recently_added_pictures
    load_module_preferences

    @left_modules = [
        :render_topic_box,
        :render_search,
        :render_tagcloud,
        :render_most_lovable_places,
        :render_recently_added_places]
  end

  private
    def load_paginated_restaurants
      page = params[:page].to_i > 0 ? params[:page].to_i : 1
      joins = ''
      conditions = ''
      @tag_ids.each_with_index do |tag_id, index|
        joins << " LEFT JOIN tag_mappings tm#{index}
                   ON tm#{index}.restaurant_id = restaurants.id
                   AND tm#{index}.topic_id=#{@topic.id}"

        conditions << "tm#{index}.tag_id=#{tag_id}"
        if index < @tag_ids.length - 1
          conditions << ' AND '
        end
      end

      WillPaginate::Collection.create(page, Restaurant.per_page) do |pager|
        pager.replace(Restaurant.all(
            :conditions => conditions, :joins => joins,
            :offset => pager.offset, :limit => pager.per_page))

        unless pager.total_entries
          pager.total_entries = Restaurant.count(
              :conditions => conditions, :joins => joins)
        end
      end
    end

    def topic_imposed_limit_allows?
      form_attribute = @topic.form_attribute
      form_attribute && form_attribute.allows_more_entry?(@topic, current_user)
    end

end
