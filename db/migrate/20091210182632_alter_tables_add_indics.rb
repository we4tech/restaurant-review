class AlterTablesAddIndics < ActiveRecord::Migration

  def self.up
    add_index :related_images, [:image_id]
    add_index :related_images, [:user_id]
    add_index :related_images, [:restaurant_id]
    add_index :reviews, [:restaurant_id]
    add_index :reviews, [:loved]
    add_index :contributed_images, [:image_id]
    add_index :contributed_images, [:restaurant_id]
  end

  def self.down
    remove_index :related_images, [:image_id]
    remove_index :related_images, [:user_id]
    remove_index :related_images, [:restaurant_id]
    remove_index :reviews, [:restaurant_id]
    remove_index :reviews, [:loved]
    remove_index :contributed_images, [:image_id]
    remove_index :contributed_images, [:restaurant_id]
  end
end
