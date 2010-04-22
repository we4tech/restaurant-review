class FormAttributesController < ApplicationController

  before_filter :log_new_feature_visiting_status

  def edit
    topic_id = params[:topic_id].to_i
    @available_fields = Restaurant.column_names
    @available_fields = (@available_fields - [
        'id', 'user_id', 'created_at', 'updated_at', 'lat', 'lng', 'topic_id'])
    @field_types = FormAttribute::FIELD_TYPES
    @record_options = [
        ['Unlimited', FormAttribute::UNLIMITED_RECORDS],
        ['Limited', FormAttribute::LIMITED_RECORDS],
        ['Single', FormAttribute::SINGLE_RECORD]]

    if topic_id > 0
      @form_attribute = FormAttribute.by_topic(topic_id).first
    elsif (id = params[:id].to_i) > 0
      @form_attribute = FormAttribute.find(id)
    else
      flash[:notice] = 'Invalid request.'
      redirect_to :back
    end
  end

  def update
    @form_attribute = FormAttribute.find(params[:id].to_i)

    fields = []
    field_names = []
    fields_from_param = params[:site_fields]
    duplicate_form_field_found = false

    fields_from_param.each do |field|
      if !(field['field'] || '').blank?
        if !field_names.include?(field['field'])
          field_names << field['field']
          fields << field
        else
          duplicate_form_field_found = field['field']
        end
      end
    end

    fields.sort!{|v1, v2| v1['index'] <=> v2['index']}

    if @form_attribute.update_attributes(
        :fields => fields,
        :record_insert_type => params['form_attribute']['record_insert_type'].to_i,
        :allow_image_upload => params['form_attribute']['allow_image_upload'].to_i,
        :allow_contributed_image_upload => params['form_attribute']['allow_contributed_image_upload'].to_i
        )
      flash[:notice] = 'Form attributes are updated!'
    else
      flash[:notice] = "Failed to store form attribute!"
    end

    if !duplicate_form_field_found
      redirect_to edit_form_attribute_url(@form_attribute.id)
    else
      flash[:notice] = "Duplicate field '#{duplicate_form_field_found}' found!"
      redirect_to :back
    end
  end
end
