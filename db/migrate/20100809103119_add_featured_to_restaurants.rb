class AddFeaturedToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :featured, :boolean
  end

  def self.down
    remove_column :restaurants, :featured
  end
end
