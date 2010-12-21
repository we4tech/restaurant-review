class AddHostsToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :hosts, :string
    add_index :topics, [:hosts]
  end

  def self.down
    remove_column :topics, :hosts
  end
end
