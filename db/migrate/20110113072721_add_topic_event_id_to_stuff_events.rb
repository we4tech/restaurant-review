class AddTopicEventIdToStuffEvents < ActiveRecord::Migration
  def self.up
    add_column :stuff_events, :topic_event_id, :integer
  end

  def self.down
    remove_column :stuff_events, :topic_event_id
  end
end
