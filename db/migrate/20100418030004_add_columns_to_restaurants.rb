class AddColumnsToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :short_array, :string
    add_column :restaurants, :long_array, :text
    add_column :restaurants, :short_map, :string
    add_column :restaurants, :long_map, :text
  end

  def self.down
    remove_column :restaurants, :long_map
    remove_column :restaurants, :short_map
    remove_column :restaurants, :long_array
    remove_column :restaurants, :short_array
  end
end
