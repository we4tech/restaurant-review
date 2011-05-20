class AddFbPageIdToRestaurants < ActiveRecord::Migration
  def self.up
    add_column :restaurants, :fb_page_id, :integer
  end

  def self.down
    remove_column :restaurants, :fb_page_id
  end
end
