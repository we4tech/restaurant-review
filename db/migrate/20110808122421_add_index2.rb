class AddIndex2 < ActiveRecord::Migration
  def self.up
    add_index :exclude_lists, [:object_type, :list_name]
    add_index :tags, [:as_section]
    add_index :user_logs, [:user_id, :topic_id]
    add_index :checkins, [:topic_id]
    add_index :topic_events, [:topic_id, :start_at, :end_at]
    add_index :checkins, [:restaurant_id]
  end

  def self.down
    remove_index :exclude_lists, [:object_type, :list_name]
    remove_index :tags, [:as_section]
    remove_index :user_logs, [:user_id, :topic_id]
    remove_index :checkins, [:topic_id]
    remove_index :topic_events, [:topic_id, :start_at, :end_at]
    remove_index :checkins, [:restaurant_id]
  end
end
