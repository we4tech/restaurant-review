class AddEnabledToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :enabled, :boolean, :default => true
  end

  def self.down
    remove_column :topics, :enabled
  end
end
