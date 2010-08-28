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
    element = template_element(options, PremiumTemplate::GROUP_FEATURE_IMAGE)
    editor = render :partial => 'images/modules/edit_big_image_gallery',
                    :locals => {:key => element.element_key, :config => element}
    viewable = big_image_gallery(options)
    "#{editor}<div class='space_5 break'></div>#{viewable}"
  end

  #
  # Render big image gallery
  def big_image_gallery(options = {})
    config = template_element(options, PremiumTemplate::GROUP_FEATURE_IMAGE)

    images = @restaurant.related_images.
        by_group(PremiumTemplate::GROUP_FEATURE_IMAGE).collect(&:image)

    if !images.empty?
      first_image = images.first
      remaining_images = images - [first_image]
      render :partial => 'images/modules/big_image_gallery', :locals => {
          :config => config,
          :values => {
              :images => images,
              :first_image => first_image,
              :remaining_images => remaining_images,
              :config => config}}
    else
      'No Images were added!'
    end
  end
end
