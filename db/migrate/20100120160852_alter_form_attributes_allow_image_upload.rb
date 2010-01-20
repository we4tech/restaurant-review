class AlterFormAttributesAllowImageUpload < ActiveRecord::Migration

  def self.up
    add_column :form_attributes, :allow_image_upload, :boolean, :default => 1
    add_column :form_attributes, :allow_contributed_image_upload, :boolean, :default => 1
  end

  def self.down
    remove_column :form_attributes, :allow_image_upload
    remove_column :form_attributes, :allow_contributed_image_upload
  end
end
