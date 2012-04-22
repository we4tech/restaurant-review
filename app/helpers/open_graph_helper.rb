module OpenGraphHelper

  def render_meta_tags(property_name_value_maps)
    html = ""
    property_name_value_maps.each do |property, value|
      options = {
          'property' => property,
          'content' => value
      }
      html << "#{tag('meta', options, false, true)}\n" if value.present?
    end

    html
  end

  def find_attribute_value(ref_object, p_field)
    if p_field.length < 20
      multiple_fields = p_field.split('|')
      values = multiple_fields.collect{|f| ref_object.__send__ f.to_sym}.compact
      values.first
    else
      p_field
    end
  end
end
