module TagsHelper

  #
  # Render tags of the specific Tag Group as a < select and Option > fields.
  #  tag_group_name - mention the tag group name
  #  options - list of overriding options
  #            :prefix - prefix for the field label
  #            :include_blank - mention this to ensure a blank option is added
  #                             with the specified text.
  #
  def render_tags_select_field(tag_group_name, options = {})
    tag_group_name = tag_group_name || 'locations'
    label_prefix   = options.delete(:prefix)
    include_blank  = options.delete(:include_blank)
    tag_group      = TagGroup.of(@topic, tag_group_name)

    if tag_group
      option_tags = tag_group.tags.collect { |t| content_tag('option', "#{label_prefix}#{t.name}", :value => t.name) }
      if include_blank
        option_tags = [content_tag('option', include_blank, :value => '')] + option_tags
      end
      content_tag('select', option_tags, options)
    end
  end

  #
  # Render < img /> or inline CSS if section has selected restaurants and
  # if restaurant has image with *:section* group
  # Otherwise render nothing
  def render_section_editor_selected_item_image(section, inline_css = false)
    restaurant = section.editor_selected_or_top_rated(1).first
    path = nil
    image = nil

    if restaurant
      images = restaurant.images_of('section')
      if images && !images.empty?
        image = images.first.image
        path = image.large_public_filename
      else
        image = restaurant.all_images.first
        if image
          path = image.large_public_filename
        end
      end
    end

    if path
      if inline_css
        "background: url(#{path})"
      else
        tag('img', :src => path, :atl => image.caption)
      end
    end
  end

  def last_selected_tag
    if session[:last_tag_id]
      Tag.find(session[:last_tag_id])
    else
      nil
    end
  end
end
