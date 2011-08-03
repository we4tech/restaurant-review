class AjaxFragmentController < ApplicationController

  ALLOWED_FRAGMENTS = [:top_menu, :notice, :restaurant_tools,
                       :restaurant_view_tools,
                       :module_render_recently_reviewed_places,
                       :authenticity_token, :test, :best_for_box,
                       :featured_box, :page_side_modules,
                       :leader_board, :event_tools, :news_feed,
                       :event_view_tools, :image_view_tools, :image_tools]
  include RestaurantsHelper
  after_filter :no_cache

  def fragment_for
    fragment_name = (params[:name] || '').downcase.to_sym
    if !fragment_name.blank?
      parse_fragment_for(fragment_name)
    else
      render :text => ''
    end
  end

  protected
    def no_cache
      response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
      response.headers["Pragma"] = "no-cache"
    end

  private
    def parse_fragment_for(fragment_name)
      if ALLOWED_FRAGMENTS.include?(fragment_name)
        send("render_#{fragment_name.to_s}")
      else
        render :text => 'Not allowed fragments'
      end
    end

    def render_top_menu
      @content_file = 'layouts/fresh_parts/top_navigation_v3'
      @effect = "slideDown({easing: \"jswing\"}).removeClass('menuLoadingIndicator')"
      @element = '#topNavigationBar'
      render :action => 'render_fragment', :layout => false
    end

    def render_notice
      @content_text = flash[:notice] || flash[:error] || flash[:success]
      @effect = 'appear()'
      @element = '#siteNoticeBar'
      @after_effects = %{
        setTimeout(function() {
          $('#{@element}').fadeOut();
        }, 5000);
      }
      render :action => 'render_fragment', :layout => false
    end

    def render_restaurant_tools
      restaurant_ids = params[:restaurant_ids]
      @restaurants = Restaurant.find(restaurant_ids)
      params[:format] = :html
      render :action => 'render_restaurant_tools', :layout => false
    end

    def render_restaurant_view_tools
      @restaurant = Restaurant.find(params[:restaurant_id])
      @allow_image_upload = @topic.form_attribute.allow_image_upload
      @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload
      
      params[:format] = :html
      render :action => 'render_restaurant_view_tools', :layout => false
    end

    def render_event_view_tools
      @event = TopicEvent.find(params[:event_id])
      @allow_image_upload = @topic.form_attribute.allow_image_upload
      @allow_contributed_image_upload = @topic.form_attribute.allow_contributed_image_upload

      params[:format] = :html
      render :action => 'render_event_view_tools', :layout => false
    end

    def render_image_view_tools
      @image = Image.find(params[:image_id])

      params[:format] = :html
      render :action => 'render_image_view_tools', :layout => false
    end

    def render_module_render_recently_reviewed_places
      @restaurant = Restaurant.find(params[:restaurant_id])
      params[:format] = :html
      load_module_preferences
      render :action => 'render_module_recently_added_places', :layout => false
    end

    def render_authenticity_token
      response.headers["Pragma"] = "no-cache"
      response.headers["Cache-Control"] = "no-cache"
      
      render :text => %{
      $('form input').each(function() {
        if ($(this).attr('name') == 'authenticity_token') {
          $(this).val("#{form_authenticity_token}");
        }
      });
      }
    end

    def render_best_for_box
      cache_fragment("best_for_box_#{@topic.name}") do
        @content_file = 'restaurants/parts/best_for'
        @effect = "appear().removeClass('loadingIndicator')"
        @element = '#categoryHitRestaurantBox'
        @best_for_tags = Tag.featurable(@topic.id)
        if @best_for_tags.present?
          render :partial => 'ajax_fragment/render_fragment', :layout => false
        else
          render :text => ''
        end
      end
    end

    def render_featured_box
      cache_fragment("featured_box_#{@topic.name}") do 
        @content_file = 'restaurants/parts/top_rated_slider'
        @effect = 'appear()'
        @element = '#featureBox'
        @top_rated_restaurants = Restaurant.featured(@topic.id)
        render :partial => 'ajax_fragment/render_fragment', :layout => false
      end
    end

    def render_test
      render :text => "alert('hola')"  
    end

    def render_page_side_modules
      @content_file = 'layouts/fresh_parts/modules'
      @effect = "slideDown({easing: \"jswing\"}).removeClass('loadingIndicator')"
      @element = '#right_side_boxes'
      render :action => 'render_fragment', :layout => false
    end

    def render_leader_board
      @content_file = 'layouts/fresh_parts/leader_board'
      @effect = "slideDown({easing: \"jswing\"}).removeClass('loadingIndicator')"
      @element = '#leader_board_box'
      render :action => 'render_fragment', :layout => false
    end

    def render_event_tools
      event_ids = params[:event_ids]
      @events = TopicEvent.find(event_ids)
      params[:format] = :html
      render :action => 'render_event_tools', :layout => false
    end

    def render_image_tools
      image_ids = params[:image_ids]
      @images = Image.find(image_ids)
      params[:format] = :html
      render :action => 'render_image_tools', :layout => false
    end

    def render_news_feed
      @content_file = 'layouts/fresh_parts/news_feed'
      @effect = "slideDown({easing: \"jswing\"}).removeClass('loadingIndicator')"
      @element = '#news_feed_box'
      render :action => 'render_fragment', :layout => false
    end
    
end
