class CreateReviews < ActiveRecord::Migration
  def self.up
    create_table :reviews do |t|
      t.integer :restaurant_id
      t.integer :user_id
      t.integer :loved, :default => 1
      t.text :comment
      t.integer :status, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :reviews
  end
end
