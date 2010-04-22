class AddIndexToTagsAndTagMappings < ActiveRecord::Migration

  def self.up
    add_index :tags, [:name, :topic_id]
    add_index :tag_mappings, [:topic_id, :tag_id]
    add_index :tag_mappings, [:restaurant_id]
  end

  def self.down
    remove_index :tags, [:name, :topic_id]
    remove_index :tag_mappings, [:topic_id, :tag_id]
    remove_index :tag_mappings, [:restaurant_id]
  end
end
