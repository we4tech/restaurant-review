class CreateRelatedImages < ActiveRecord::Migration
  def self.up
    create_table :related_images do |t|
      t.integer :image_id, :restaurant_id
      t.string :model
      t.string :group

      t.timestamps
    end
  end

  def self.down
    drop_table :related_images
  end
end
