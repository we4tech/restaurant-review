class CreateRelatedTags < ActiveRecord::Migration
  def self.up
    create_table :related_tags do |t|
      t.integer :group_id
      t.integer :tag_id
      t.integer :topic_id

      t.timestamps
    end
  end

  def self.down
    drop_table :related_tags
  end
end
