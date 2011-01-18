class CreateTopicEvents < ActiveRecord::Migration
  def self.up
    create_table :topic_events do |t|
      t.integer :topic_id
      t.integer :user_id
      t.integer :event_type
      t.integer :parent_event_id
      t.string :name
      t.text :description
      t.text :description_fields
      t.string :address
      t.float :lat
      t.float :lng
      t.datetime :start_at
      t.datetime :end_at
      t.text :daily_schedule_map
      t.boolean :suspended, :default => false
      t.boolean :completed, :default => false
      t.text :suspending_reason

      t.timestamps
    end

    add_index :topic_events, [:topic_id]
  end

  def self.down
    drop_table :topic_events
  end
end
