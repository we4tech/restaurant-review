class AddTopicEventIdToPhotoComments < ActiveRecord::Migration
  def self.up
    add_column :photo_comments, :topic_event_id, :integer
  end

  def self.down
    remove_column :photo_comments, :topic_event_id
  end
end
