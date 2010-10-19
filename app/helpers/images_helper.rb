module ImagesHelper

  def render_image_editor(bind_with, options = {})
    related_field, related_field_value = find_field_and_value_from_bindable_object(bind_with, options)

    render :partial => 'images/parts/editor', :locals => {
        :related_field => related_field,
        :related_field_value => related_field_value
    }.merge(options)
  end

  def render_related_images(object, options = {})
    image_type = options[:image_type] || :c_small
    images = object.images
    if options.keys.include?(:start)
      images = images[options[:start]..images.length]
    end

    gallery_type = options[:type] ? "_#{options[:type].to_s}_" : '_'
    if !images.empty?
      render :partial => "images/parts/image#{gallery_type}gallery",
             :object => object,
             :locals => {:images => images, :gallery_type => gallery_type,
                         :image_type => image_type, :css_class => options[:css_class]}
    end
  end

  private
    def find_field_and_value_from_bindable_object(bind_with, options)
      field = "#{bind_with.to_s}_id"
      value = (options.include?(bind_with) ? options[bind_with] : instance_variable_get("@#{bind_with.to_s}")).send(:id)
      return field, value
    end
end
