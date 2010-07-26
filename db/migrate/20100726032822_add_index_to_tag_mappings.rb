class AddIndexToTagMappings < ActiveRecord::Migration
  def self.up
    remove_index :tag_mappings, [:tag_id]
    remove_index :tag_mappings, [:tag_id, :topic_id]
    remove_index :tag_mappings, [:restaurant_id]
    add_index :tag_mappings, [:tag_id, :restaurant_id, :topic_id]
  end

  def self.down
    add_index :tag_mappings, [:tag_id]
    add_index :tag_mappings, [:tag_id, :topic_id]
    add_index :tag_mappings, [:restaurant_id]
    remove_index :tag_mappings, [:tag_id, :restaurant_id, :topic_id]
  end
end
