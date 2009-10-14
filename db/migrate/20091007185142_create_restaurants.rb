class CreateRestaurants < ActiveRecord::Migration
  def self.up
    create_table :restaurants do |t|
      t.string :name
      t.text :description
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :restaurants
  end
end
