class AddCounterCacheForTopicEventRestaurantAndUser < ActiveRecord::Migration
  def self.up
    add_column :users, :checkins_count, :integer
    add_column :restaurants, :checkins_count, :integer
    add_column :topic_events, :checkins_count, :integer
  end

  def self.down
    remove_column :users, :checkins_count
    remove_column :restaurants, :checkins_count
    remove_column :topic_events, :checkins_count
  end
end
