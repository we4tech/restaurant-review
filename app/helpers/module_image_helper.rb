module ModuleImageHelper

  DEFAULT_BANNER_IMAGE_KEY = 'top_banner_image'

  #
  # Render banner image editor
  def edit_banner_image(options = {})
    key = options.stringify_keys['key'] || DEFAULT_BANNER_IMAGE_KEY

    editor = render :partial => 'images/modules/edit_banner_image',
                    :object => @premium_template.find_or_create_element(key)
    viewable = banner_image(options)
    "#{editor}<div class='space_5 break'></div>#{viewable}"
  end

  #
  # Render user uploaded image
  def banner_image(options = {})
    key = options.stringify_keys['key'] || DEFAULT_BANNER_IMAGE_KEY
    element = @premium_template.find_or_create_element(key)

    related_image = @restaurant.related_images.
        by_group(PremiumTemplate::GROUP_BANNER_IMAGE).first
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
  def edit_big_image_gallery(options = {})
    editor = render :partial => 'images/modules/edit_big_image_gallery'
    viewable = big_image_gallery(options)
    "#{editor}<div class='space_5 break'></div>#{viewable}"
  end

  #
  # Render big image gallery
  def big_image_gallery(options = {})
    images = @restaurant.related_images.
        by_group(PremiumTemplate::GROUP_FEATURE_IMAGE).collect(&:image)

    if !images.empty?
      first_image = images.first
      remaining_images = images - [first_image]
      render :partial => 'images/modules/big_image_gallery', :locals => {
          :images => images,
          :first_image => first_image,
          :remaining_images => remaining_images}
    else
      'No Images were added!'
    end
  end
end
