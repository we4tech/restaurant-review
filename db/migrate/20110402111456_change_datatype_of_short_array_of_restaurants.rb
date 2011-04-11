class ChangeDatatypeOfShortArrayOfRestaurants < ActiveRecord::Migration

  def self.up
    change_column :restaurants, :short_array, :text
    change_column :restaurants, :short_map, :text
  end

  def self.down
    change_column :restaurants, :short_array, :string
    change_column :restaurants, :short_map, :string
  end
end
