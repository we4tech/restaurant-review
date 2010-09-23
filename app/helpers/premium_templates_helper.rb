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

  def template_element(options, default_key)
    key = options.stringify_keys['key'] || default_key
    @premium_template.find_or_create_element(key)
  end

  def pt_render_template(file)
    render :template => "templates/#{@premium_template.template}/#{file}", :layout => false
  end

  def pt_render_view
    if @premium_template.activate_coming_soon?
      @premium_service_subscriber = PremiumServiceSubscriber.new
      pt_render_template('coming_soon')
    elsif @premium_template.activate_under_construction?
      pt_render_template('under_construction')
    else
      pt_render_template('layout')
    end
  end

  def pt_stylesheet_link_tag(files)
    if !files.is_a?(Array)
      files = [files]
    end

    stylesheet_link_tag files.collect{|f| "templates/#{@premium_template.template}/#{f}"}
  end
end
