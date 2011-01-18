class AddTopicEventIdToReviewComments < ActiveRecord::Migration
  def self.up
    add_column :review_comments, :topic_event_id, :integer
  end

  def self.down
    remove_column :review_comments, :topic_event_id
  end
end
