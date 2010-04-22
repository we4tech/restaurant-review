class AddUsagesCountToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :usages_count, :integer, :default => 0
  end

  def self.down
    remove_column :tags, :usages_count
  end
end
