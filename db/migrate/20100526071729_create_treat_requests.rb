class CreateTreatRequests < ActiveRecord::Migration
  def self.up
    create_table :treat_requests do |t|
      t.integer :topic_id
      t.integer :restaurant_id
      t.integer :uid
      t.integer :requested_uid
      t.boolean :accepted
      t.boolean :denied

      t.timestamps
    end
  end

  def self.down
    drop_table :treat_requests
  end
end
