class CreateResourceImporters < ActiveRecord::Migration
  def self.up
    create_table :resource_importers do |t|
      t.string :model
      t.string :import_status
      t.text :error
      t.integer :imported_items
      t.integer :failure_items
      t.text :failure_items_inspection
      t.integer :topic_id
      t.integer :user_id
      t.text :imported_item_ids

      t.timestamps
    end
  end

  def self.down
    drop_table :resource_importers
  end
end
