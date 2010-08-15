class AddPremiumToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :premium, :boolean
  end

  def self.down
    remove_column :restaurants, :premium
  end
end
