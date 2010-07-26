class CreateTagGroupMappings < ActiveRecord::Migration
  def self.up
    create_table :tag_group_mappings do |t|
      t.integer :tag_id
      t.integer :tag_group_id
      t.integer :topic_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tag_group_mappings
  end
end
