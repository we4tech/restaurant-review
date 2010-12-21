class AddGmapKeyToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :gmap_key, :text
  end

  def self.down
    remove_column :topics, :gmap_key
  end
end
