class CreateFoodItems < ActiveRecord::Migration
  def self.up
    create_table :food_items do |t|
      t.string :name
      t.integer :user_id, :restaurant_id, :food_item_id
      t.text :description
      t.text :related_objects
      t.float :price

      t.timestamps
    end
  end

  def self.down
    drop_table :food_items
  end
end
