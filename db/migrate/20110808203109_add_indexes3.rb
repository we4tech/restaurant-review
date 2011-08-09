class AddIndexes3 < ActiveRecord::Migration
  def self.up
    add_index :review_comments, [:review_id]
    add_index :checkins, [:topic_event_id]
    add_index :photo_comments, [:image_id]
    add_index :images, [:parent_id, :thumbnail]
  end

  def self.down
    remove_index :review_comments, [:review_id]
    remove_index :checkins, [:topic_event_id]
    remove_index :photo_comments, [:image_id]
    remove_index :images, [:parent_id, :thumbnail]
  end
end
