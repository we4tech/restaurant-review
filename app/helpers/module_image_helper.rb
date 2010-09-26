module ModuleImageHelper

  DEFAULT_BANNER_IMAGE_KEY = 'top_banner_image'

  #
  # Render banner image editor
  def edit_uploaded_image(options = {})
    editor = render :partial => 'images/modules/edit_uploaded_image',
                    :object => template_element(options, DEFAULT_BANNER_IMAGE_KEY)
    viewable = uploaded_image(options)
    "#{editor}<div class='space_5 break'></div>#{viewable}"
  end

  #
  # Render user uploaded image
  def uploaded_image(options = {})
    element = template_element(options, DEFAULT_BANNER_IMAGE_KEY)

    related_image = @restaurant.related_images.
        by_group(options[:key] || PremiumTemplate::GROUP_BANNER_IMAGE).first
    bgcolor = element.data.first ? element.data.first['bgcolor'] : 'red'

    if related_image
      "<div class='bgcolor' style='background:#{bgcolor}'>
        #{image_tag(related_image.image.public_filename,
                    :alt => related_image.image.caption,
                    :title => related_image.image.caption)}
      </div>"
    else
      'No Banner was added!'
    end
  end

  #
  # Render big image gallery for edit
  def edit_big_image_gallery(options = {}, &block)
    element = template_element(options, PremiumTemplate::GROUP_FEATURE_IMAGE)
    images = @restaurant.related_images.
        by_group(options[:key] || PremiumTemplate::GROUP_FEATURE_IMAGE).
        collect(&:image).sort{|a, b| a.created_at <=> b.created_at}

    if !block_given?
      render_big_image_gallery_edit_view(options, element, images)
    else
      block.call(:edit, element, wrap_object({
          :html => render_big_image_gallery_edit_view(
              options, element, images, &block)}))
    end
  end

  def render_big_image_gallery_edit_view(options, element, images, &block)
    editor = render :partial => 'images/modules/edit_big_image_gallery',
                    :locals => {
                        :key => element.element_key,
                        :config => element,
                        :images => images}

    if !block
      viewable = big_image_gallery(options)
      "#{editor}<div class='space_5 break'></div>#{viewable}"
    else
      images = images.collect{ |img| img if img.display? }.compact
      viewable = block.call(:view, element, images)
      "#{editor}"
    end
  end

  #
  # Render big image gallery
  def big_image_gallery(options = {})
    config = template_element(options, PremiumTemplate::GROUP_FEATURE_IMAGE)
    images = @restaurant.related_images.
        by_group(options[:key] || PremiumTemplate::GROUP_FEATURE_IMAGE).
        collect(&:image).sort{|a, b| a.created_at <=> b.created_at}
    
    images = images.collect{ |img| img if img.display? }.compact

    if !images.empty?
      if !block_given?
        render_big_image_gallery_view(config, images)
      else
        yield(:view, config, images)
      end
    else
      'No Images were added!'
    end
  end

  def render_big_image_gallery_view(config, images)
    first_image = images.first
    remaining_images = images - [first_image]
    render :partial => 'images/modules/big_image_gallery', :locals => {
        :config => config,
        :values => {
            :images => images,
            :first_image => first_image,
            :remaining_images => remaining_images,
            :config => config}}
  end
end
