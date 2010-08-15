class AddFoodItemIdToRelatedImages < ActiveRecord::Migration
  def self.up
    add_column :related_images, :food_item_id, :integer
  end

  def self.down
    remove_column :related_images, :food_item_id
  end
end
