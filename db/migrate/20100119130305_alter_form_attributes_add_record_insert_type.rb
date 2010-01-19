class AlterFormAttributesAddRecordInsertType < ActiveRecord::Migration

  def self.up
    add_column :form_attributes, :record_insert_type, :integer, :default => 0
  end

  def self.down
    remove_column :form_attributes, :record_insert_type
  end
end
