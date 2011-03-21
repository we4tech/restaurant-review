class AddFbIdAndOgTypeToTopics < ActiveRecord::Migration
  def self.up
    add_column :topics, :fb_id, :string
    add_column :topics, :fb_admins, :string
    add_column :topics, :og_type, :string
  end

  def self.down
    remove_column :topics, :og_type
    remove_column :topics, :fb_admins
    remove_column :topics, :fb_id
  end
end
