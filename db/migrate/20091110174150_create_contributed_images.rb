class CreateContributedImages < ActiveRecord::Migration
  def self.up
    create_table :contributed_images do |t|
      t.integer :user_id, :restaurant_id, :image_id
      t.string :model, :group
      t.integer :status, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :contributed_images
  end
end
