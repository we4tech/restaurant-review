class AddTagMappingsCountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :tag_mappings_count, :integer, :default => 0
  end

  def self.down
    remove_column :tags, :tag_mappings_count
  end
end
