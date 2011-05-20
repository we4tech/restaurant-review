class CreateCheckins < ActiveRecord::Migration
  def self.up
    create_table :checkins do |t|
      t.integer :topic_id
      t.integer :restaurant_id
      t.integer :topic_event_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :checkins
  end
end
