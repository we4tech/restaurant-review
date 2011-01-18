class AddTopicEventIdToReviews < ActiveRecord::Migration
  def self.up
    add_column :reviews, :topic_event_id, :integer
    add_index :reviews, [:topic_event_id]
  end

  def self.down
    remove_column :reviews, :topic_event_id
  end
end
