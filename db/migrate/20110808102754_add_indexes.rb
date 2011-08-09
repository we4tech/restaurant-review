class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :site_policies, [:name]
    add_index :topics, [:enabled]
    add_index :review_comments, [:topic_id, :user_id]
    add_index :checkins, [:user_id, :topic_id]
    add_index :tag_groups, [:topic_id, :name]
    add_index :images, [:user_id]
  end

  def self.down
    remove_index :site_policies, [:name]
    remove_index :topics, [:enabled]
    remove_index :review_comments, [:topic_id, :user_id]
    remove_index :checkins, [:user_id, :topic_id]
    remove_index :tag_groups, [:topic_id, :name]
    remove_index :images, [:user_id]
  end
end
