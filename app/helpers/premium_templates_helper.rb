module PremiumTemplatesHelper

  AVAILABLE_MODULES = [
      :uploaded_image, :dynamic_menu,
      :big_image_gallery, :rich_text,
      :video_gallery, :recent_news,
      :search, :recent_reviews]

  #
  # Render module of the specified type
  def render_module(type, options = {}, &block)
    if AVAILABLE_MODULES.include?(type)
      if @edit_mode
        if !block_given?
          send("edit_#{type.to_s}", options)
        else
          send("edit_#{type.to_s}", options, &block)
        end
      else
        if !block_given?
          send(type, options)
        else
          send(type, options, &block)
        end
      end
    else
      "No such module - #{type} found!"
    end
  end

  def wrap_object(hash_map)
    instance = Object.new
    instance.class_eval do
      hash_map.keys.each do |method_name|
        define_method(method_name.to_sym) {hash_map[method_name]}  
      end
    end
    instance
  end

  def store_last_premium_site_host(override_host = nil)
    session[:__site_host] = "http://#{override_host || request.host}"
  end

  def last_premium_site_host
    session[:__site_host]
  end

  def template_element(options, default_key)
    key = options.stringify_keys['key'] || default_key
    @premium_template.find_or_create_element(key)
  end

  def pt_render_template(file)
    render :template => "templates/#{@premium_template.template}/#{file}", :layout => false
  end

  def pt_render_view
    if @premium_template.activate_coming_soon? &&
        !@premium_template.match_test_host?(request.host)  
      if params[:premium_service_subscriber].nil?
        @premium_service_subscriber = PremiumServiceSubscriber.new
      end
      pt_render_template('coming_soon')
    elsif @premium_template.activate_under_construction? &&
        !@premium_template.match_test_host?(request.host)
      pt_render_template('under_construction')
    else
      pt_render_template('layout')
    end
  end

  def pt_render_partial(file)
    render :partial => "templates/#{@premium_template.template}/#{file}"
  end

  def pt_stylesheet_link_tag(files)
    if !files.is_a?(Array)
      files = [files]
    end

    stylesheet_link_tag files.collect{|f| "templates/#{@premium_template.template}/#{f}"}
  end

  def pt_redirect_to_root(or_redirect_to = nil)
    redirect_to or_redirect_to || last_premium_site_host
  end

  def pt_activate_no_reference_url?
    @premium_template.activate_no_reference_url? || last_premium_site_host
  end

end
