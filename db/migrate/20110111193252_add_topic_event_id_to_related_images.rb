class AddTopicEventIdToRelatedImages < ActiveRecord::Migration
  def self.up
    add_column :related_images, :topic_event_id, :integer
    add_index :related_images, [:topic_event_id]
  end

  def self.down
    remove_column :related_images, :topic_event_id
  end
end
