class AddFbConnectKeyToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :fb_connect_key, :text
    add_column :topics, :fb_connect_secret, :text
  end

  def self.down
    remove_column :topics, :fb_connect_key
    remove_column :topics, :fb_connect_secret
  end
end
