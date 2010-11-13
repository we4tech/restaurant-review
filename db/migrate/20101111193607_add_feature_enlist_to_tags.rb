class AddFeatureEnlistToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :feature_enlist, :boolean, :default => false
  end

  def self.down
    remove_column :tags, :feature_enlist
  end
end
