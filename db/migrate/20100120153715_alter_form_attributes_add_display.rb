class AlterFormAttributesAddDisplay < ActiveRecord::Migration

  def self.up
    FormAttribute.all.each do |form_attribute|
      formatted_fields = []

      fields = form_attribute.fields
      fields.each do |field|
        formatted_field = {}
        field.each {|k, v| formatted_field[k.to_s] = v}
        formatted_field['display'] = true

        formatted_fields << formatted_field
      end

      form_attribute.update_attribute(:fields, formatted_fields)
    end
  end

  def self.down
  end
end
