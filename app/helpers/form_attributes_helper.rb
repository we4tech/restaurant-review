module FormAttributesHelper

  #
  # Render dynamic holder for accommodating expandable dynamic fields
  # Parameters -
  #   model_name    - Domain model name
  #   field_name    - Model field name
  #   options       - Options for overriding features
  #   html_options  - Defining html class or id
  def render_dynamic_fields_container(model_name, field_name, options = {}, html_options = {})
    value = instance_variable_get("@#{model_name.to_s}").__send__(field_name) || {}
    name = "#{model_name.to_s}[#{field_name}][]"
    render :partial => 'form_attributes/parts/dynamic_fields',
           :locals => {:value => value, :name => name}
  end
end
