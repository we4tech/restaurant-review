class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.integer :restaurant_id
      t.integer :user_id
      t.integer :topic_id
      t.string :name
      t.text :description
      t.float :price
      t.text :properties

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
