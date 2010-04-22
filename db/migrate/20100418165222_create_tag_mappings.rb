class CreateTagMappings < ActiveRecord::Migration
  def self.up
    create_table :tag_mappings do |t|
      t.integer :tag_id
      t.integer :topic_id
      t.integer :user_id
      t.integer :restaurant_id

      t.timestamps
    end

    add_index :tag_mappings, [:tag_id, :topic_id]
  end

  def self.down
    drop_table :tag_mappings
  end
end
