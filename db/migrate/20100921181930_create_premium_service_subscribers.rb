class CreatePremiumServiceSubscribers < ActiveRecord::Migration
  def self.up
    create_table :premium_service_subscribers do |t|
      t.string :email
      t.integer :restaurant_id

      t.timestamps
    end
  end

  def self.down
    drop_table :premium_service_subscribers
  end
end
