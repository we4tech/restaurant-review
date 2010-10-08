module ImagesHelper

  def render_image_editor(bind_with, options = {})
    related_field, related_field_value = find_field_and_value_from_bindable_object(bind_with, options)

    render :partial => 'images/parts/editor', :locals => {
        :related_field => related_field,
        :related_field_value => related_field_value
    }.merge(options)
  end

  private
    def find_field_and_value_from_bindable_object(bind_with, options)
      field = "#{bind_with.to_s}_id"
      value = (options.include?(bind_with) ? options[bind_with] : instance_variable_get("@#{bind_with.to_s}")).send(:id)
      return field, value
    end
end
